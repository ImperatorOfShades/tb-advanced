require 'rails_helper'

RSpec.describe 'Answers API' do
  describe 'GET /index' do
    let!(:question) { create(:question) }
    it_behaves_like 'API Authenticable' do
      let(:empty_request) { get "/api/v1/questions/#{question.id}/answers", params: { format: :json } }
      let(:wrong_token_request) { get "/api/v1/questions/#{question.id}/answers", params: { format: :json, access_token: '1234' } }
    end

    context 'authorized' do
      let(:access_token) { create(:access_token) }
      let!(:answers) { create_list(:answer, 2, question: question) }
      let!(:answer) { answers.first }
      let!(:comment) { create(:comment, commentable_type: 'Answer', commentable_id: answer.id) }
      let!(:attachment) { create(:attachment, attachable_type: 'Answer', attachable_id: answer.id) }

      before { get "/api/v1/questions/#{question.id}/answers", params: { format: :json, access_token: access_token.token } }

      it 'returns 200 status code' do
        expect(response).to be_success
      end

      it 'returns list of answers' do
        expect(response.body).to have_json_size(2)
      end

      %w[id body created_at].each do |attr|
        it "answer object contains #{attr}" do
          expect(response.body).to be_json_eql(answer.send(attr.to_sym).to_json).at_path("0/#{attr}")
        end
      end

      it_behaves_like 'comment and attachment' do
        let(:path) { '0/' }
      end
    end
  end

  describe 'GET /show' do
    let!(:question) { create(:question) }
    let!(:answer) { create(:answer, id: 1, question: question) }
    it_behaves_like 'API Authenticable' do
      let(:empty_request) { get "/api/v1/questions/#{question.id}/answers/1", params: { format: :json } }
      let(:wrong_token_request) { get "/api/v1/questions/#{question.id}/answers/1", params: { format: :json, access_token: '1234' } }
    end

    context 'authorized' do
      let(:access_token) { create(:access_token) }
      let!(:comment) { create(:comment, commentable_type: 'Answer', commentable_id: answer.id) }
      let!(:attachment) { create(:attachment, attachable_type: 'Answer', attachable_id: answer.id) }

      before { get "/api/v1/questions/#{question.id}/answers/1", params: { format: :json, access_token: access_token.token } }

      it 'returns 200 status code' do
        expect(response).to be_success
      end

      %w[id body created_at].each do |attr|
        it "question object contains #{attr}" do
          expect(response.body).to be_json_eql(answer.send(attr.to_sym).to_json).at_path(attr)
        end
      end

      it_behaves_like 'comment and attachment' do
        let(:path) { '' }
      end
    end
  end

  describe 'POST /create' do
    let!(:question) { create(:question) }
    it_behaves_like 'API Authenticable' do
      let(:empty_request) { post "/api/v1/questions/#{question.id}/answers", params: { format: :json } }
      let(:wrong_token_request) { post "/api/v1/questions/#{question.id}/answers", params: { format: :json, access_token: '1234' } }
    end

    context 'authorized' do
      let(:access_token) { create(:access_token) }
      let(:answer_params) { attributes_for(:answer, question: question) }

      before { post "/api/v1/questions/#{question.id}/answers", params: { format: :json, access_token: access_token.token, answer: answer_params, question_id: question.id} }

      it 'returns 201 status code' do
        expect(response).to have_http_status :created
      end

      %w[body].each do |attr|
        it "answer object contains #{attr}" do
          expect(response.body).to be_json_eql(answer_params[(attr.to_sym)].to_json).at_path("#{attr}")
        end
      end

      context 'comments' do
        it 'included in answer object' do
          expect(response.body).to have_json_size(0).at_path('comments')
        end
      end

      context 'attachments' do
        it 'included in answer object' do
          expect(response.body).to have_json_size(0).at_path('attachments')
        end
      end
    end
  end
end
