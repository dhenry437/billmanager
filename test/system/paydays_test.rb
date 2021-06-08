require "application_system_test_case"

class PaydaysTest < ApplicationSystemTestCase
  setup do
    @payday = paydays(:one)
  end

  test "visiting the index" do
    visit paydays_url
    assert_selector "h1", text: "Paydays"
  end

  test "creating a Payday" do
    visit paydays_url
    click_on "New Payday"

    fill_in "Date", with: @payday.date
    fill_in "Name", with: @payday.name
    fill_in "Reccuring", with: @payday.reccuring
    click_on "Create Payday"

    assert_text "Payday was successfully created"
    click_on "Back"
  end

  test "updating a Payday" do
    visit paydays_url
    click_on "Edit", match: :first

    fill_in "Date", with: @payday.date
    fill_in "Name", with: @payday.name
    fill_in "Reccuring", with: @payday.reccuring
    click_on "Update Payday"

    assert_text "Payday was successfully updated"
    click_on "Back"
  end

  test "destroying a Payday" do
    visit paydays_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Payday was successfully destroyed"
  end
end
