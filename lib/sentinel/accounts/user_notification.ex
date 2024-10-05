defmodule Sentinel.Accounts.UserNotification do
  import Swoosh.Email

  def email_by_camera_brand(%{name: name, email: email, brand: brand}) do
    body = """
    <h1>#{brand} Camera Update</h1>
    <p>Hello #{name},</p>
    <p>We have important information about your #{brand} camera(s).</p>
    <p>Please check your account for more details.</p>
    """

    new()
    |> to({name, email})
    |> from({"Sentinel", "notification@sentinel.com"})
    |> subject("#{brand} Camera Update")
    |> html_body(body)
  end
end
