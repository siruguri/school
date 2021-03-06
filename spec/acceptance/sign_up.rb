require 'spec_helper'

feature %q{
  As a user
  I want to be able to sign up
  So I can participate
} do

  background do
    visit root_path
    click_link "Sign up"
  end

  scenario "Sign up" do
    fill_in "user[email]", with: "stewie@example.com"
    fill_in "user[name]", with: "Stewie"
    fill_in "user[password]", with: "draft1"
    fill_in "user[password_confirmation]", with: "draft1"
    fill_in "user[homepage]", with: "google.com"
    click_button "Sign up"
    within ".center-column" do
      page.should_not have_content "Sign up"
    end
    user = User.last.reload
    user.name.should == "Stewie"
    user.email.should == "stewie@example.com"
    user.homepage.should == "http://google.com"
  end
end
