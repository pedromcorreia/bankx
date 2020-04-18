defmodule BankxWeb.ProfileView do
  use BankxWeb, :view
  alias BankxWeb.ProfileView

  def render("index.json", %{profiles: profiles}) do
    %{data: render_many(profiles, ProfileView, "profile.json")}
  end

  def render("show.json", %{profile: profile}) do
    %{data: render_one(profile, ProfileView, "profile.json")}
  end

  def render("profile.json", %{profile: profile = %{status: :completed}}) do
    %{referral_code: profile.referral_code, status: profile.status}
  end

  def render("profile.json", %{profile: profile = %{status: :pending}}) do
    %{status: profile.status}
  end
end
