require_relative '../feature_helper'

feature 'Answer the question', %q{
  In order to answer for question
  As an Authenticated user
  I want to be able to create answer
} do

  given(:user) { create(:user) }
  given(:question) { create(:question) }

  scenario 'Authenticated user creates answer', js: true do
    sign_in user

    visit question_path(question)
    fill_in 'Answer', with: 'Test answer'
    click_on 'Add Answer'

    within '.answers' do
      expect(page).to have_content 'Test answer'
    end
    expect(current_path).to eq question_path(question)
  end

  scenario 'Not authenticated user tries creates answer' do
    visit question_path(question)
    fill_in 'Answer', with: 'Test answer'
    click_on 'Add Answer'

    expect(page).to have_content 'You need to sign in or sign up'
    expect(current_path).to eq new_user_session_path
  end

  scenario 'User try create invalid answer', js: true do
    sign_in user
    visit question_path(question)

    click_on 'Add Answer'

    expect(page).to have_content 'Answer can\'t be blank'
  end
end
