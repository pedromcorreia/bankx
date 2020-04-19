defmodule BankxWeb.ProfileView do
  use BankxWeb, :view
  alias BankxWeb.ProfileView
  alias Bankx.Encryption.{EncryptedField, HashField}

  def render("index.json", %{profiles: profiles}) do
    %{data: render_many(profiles, ProfileView, "profile.json")}
  end

  def render("show.json", %{profile: profile = %{status: :completed, profiles: profiles}}) do
    %{data: render_one(profile, ProfileView, "profile.json")}
  end

  def render("show.json", %{profile: profile}) do
    %{data: render_one(profile, ProfileView, "profile.json")}
  end

  def render("profile.json", %{profile: profile = %{status: :completed, profiles: nil}}) do
    %{referral_code: profile.referral_code, status: :completed}
  end

  def render("profile.json", %{profile: profile = %{status: :completed, profiles: profiles}})
      when is_list(profiles) do
    %{indications: indications(profiles)}
  end

  def render("profile.json", %{profile: profile = %{status: :completed, profiles: profiles}}) do
    %{referral_code: profile.referral_code, status: :completed}
  end

  def render("profile.json", %{profile: %{status: :pending}}) do
    %{status: :pending}
  end

  defp indications(profiles) do
    Enum.map(profiles, fn profile ->
      {:ok, name} = EncryptedField.load(profile.name)
      %{id: profile.id, name: name}
    end)
  end
end
