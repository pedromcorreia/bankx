defmodule BankxWeb.ProfileView do
  use BankxWeb, :view
  alias BankxWeb.ProfileView

  def render("index.json", %{profiles: profiles}) do
    %{data: render_many(profiles, ProfileView, "profile.json")}
  end

  def render("show.json", %{profile: profile}) do
    %{data: render_one(profile, ProfileView, "profile.json")}
  end

  def render("profile.json", %{profile: profile}) do
    %{id: profile.id,
      name: profile.name,
      email: profile.email,
      cpf: profile.cpf,
      birth_date: profile.birth_date,
      gender: profile.gender,
      city: profile.city,
      state: profile.state,
      country: profile.country,
      status: profile.status}
  end
end
