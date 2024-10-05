defmodule Sentinel.Notifications.Email do
  use GenServer
  require Logger

  alias Sentinel.Notifications.EmailState

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    schedule_dead_letter_processing()
    {:ok, EmailState.new()}
  end

  ##############
  # Public API #
  ##############

  @spec send_bulk_emails(list(map)) :: :ok
  def send_bulk_emails(emails) do
    GenServer.cast(__MODULE__, {:send_bulk_emails, emails})
  end

  ###############
  # Private API #
  ###############

  @impl true
  def handle_cast({:send_bulk_emails, emails}, state) do
    new_state =
      Enum.reduce(emails, state, fn email, acc ->
        EmailState.enqueue_email(acc, email)
      end)

    {:noreply, process_queue(new_state)}
  end

  @impl true
  def handle_cast({:email_result, email, success?}, state) do
    new_state =
      if success? do
        EmailState.reset_circuit_breaker(state)
      else
        state
        |> EmailState.update_circuit_breaker()
        |> EmailState.enqueue_dead_letters(email)
      end

    {:noreply, process_queue(new_state)}
  end

  @impl true
  def handle_info(:reset_circuit_breaker, state) do
    Logger.info("Resetting circuit breaker...")
    {:noreply, EmailState.reset_circuit_breaker(state)}
  end

  @impl true
  def handle_info(:process_dead_letters, state) do
    Logger.info("Processing dead letters...")
    new_state = EmailState.process_dead_letters(state)
    schedule_dead_letter_processing()
    {:noreply, process_queue(new_state)}
  end

  defp process_queue(state) do
    if EmailState.circuit_breaker_open?(state) do
      Logger.warning("Circuit breaker is open. Skipping email sending.")
      state
    else
      case EmailState.dequeue_email(state) do
        {nil, new_state} ->
          new_state

        {email, new_state} ->
          send_email_async(email)
          process_queue(new_state)
      end
    end
  end

  defp send_email_async(email) do
    Task.start(fn ->
      result = do_send_email(email)
      GenServer.cast(__MODULE__, {:email_result, email, result == :ok})
    end)
  end

  defp do_send_email(%Swoosh.Email{to: [{_, user_email}]} = email, retries \\ 0) do
    if retries < config(:max_retries) do
      try do
        case Sentinel.Mailer.deliver(email) do
          {:ok, _} ->
            Logger.info("Email sent successfully to #{user_email}")
            :ok

          {:error, reason} ->
            Logger.error(
              "Failed to send email to #{user_email}. Reason: #{inspect(reason)}. Retrying..."
            )

            handle_sending_error(email, retries + 1)
        end
      rescue
        e ->
          Logger.error("Failed to send email: #{inspect(e)}. Retrying...")
          handle_sending_error(email, retries + 1)
      end
    else
      Logger.error("Max retries reached. Giving up on sending email to #{user_email}")
      :error
    end
  end

  defp handle_sending_error(email, retries) do
    Process.sleep(config(:retry_interval))
    do_send_email(email, retries + 1)
  end

  defp schedule_dead_letter_processing() do
    Process.send_after(self(), :process_dead_letters, config(:dead_letter_interval))
  end

  defp config(key) do
    :sentinel
    |> Application.fetch_env!(__MODULE__)
    |> Keyword.fetch!(key)
  end
end
