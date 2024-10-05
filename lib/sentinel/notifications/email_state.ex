defmodule Sentinel.Notifications.EmailState do
  @moduledoc """
  The state of the email sender process.
  """

  alias Sentinel.Notifications.Email

  defstruct [:queue, :circuit_breaker, :dead_letters]

  @type email :: Swoosh.Email.t()
  @type circuit_state :: :open | :closed
  @type t :: %__MODULE__{
          circuit_breaker: {circuit_state(), non_neg_integer()},
          queue: :queue.queue(email),
          dead_letters: :queue.queue(email)
        }

  @spec new() :: t
  def new() do
    %__MODULE__{
      circuit_breaker: {:closed, 0},
      dead_letters: :queue.new(),
      queue: :queue.new()
    }
  end

  @spec enqueue_email(t, email) :: t
  def enqueue_email(%{queue: queue} = state, email) do
    %{state | queue: :queue.in(email, queue)}
  end

  @spec dequeue_email(t) :: {email, t} | {nil, t}
  def dequeue_email(state) do
    case :queue.out(state.queue) do
      {{:value, email}, new_queue} ->
        {email, %{state | queue: new_queue}}

      {:empty, _} ->
        {nil, state}
    end
  end

  @spec update_circuit_breaker(t) :: t
  def update_circuit_breaker(%{circuit_breaker: {:closed, failures}} = state) do
    if failures + 1 >= config(:circuit_breaker_threshold) do
      Process.send_after(Email, :reset_circuit_breaker, config(:circuit_breaker_timeout))
      %{state | circuit_breaker: {:open, 0}}
    else
      %{state | circuit_breaker: {:closed, failures + 1}}
    end
  end

  def update_circuit_breaker(state), do: state

  @spec reset_circuit_breaker(t) :: t
  def reset_circuit_breaker(state) do
    %{state | circuit_breaker: {:closed, 0}}
  end

  @spec circuit_breaker_open?(t) :: boolean()
  def circuit_breaker_open?(%{circuit_breaker: {:open, _}}), do: true
  def circuit_breaker_open?(_), do: false

  @spec enqueue_dead_letters(t, email) :: t
  def enqueue_dead_letters(state, email) do
    %{state | dead_letters: :queue.in(email, state.dead_letters)}
  end

  @spec process_dead_letters(t) :: t
  def process_dead_letters(state) do
    new_queue = :queue.join(state.queue, state.dead_letters)
    %{state | dead_letters: :queue.new(), queue: new_queue}
  end

  defp config(key) do
    :sentinel
    |> Application.fetch_env!(__MODULE__)
    |> Keyword.fetch!(key)
  end
end
