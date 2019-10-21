require 'rails_helper'

RSpec.describe 'Parking API', type: :request do

  describe 'GET /parking' do
    let(:plate) { Faker::Base.regexify(/[A-Z]{3}-[0-9]{4}/) }
    let(:valid_attributes) { { plate: plate } }

    context 'when getting a parked vehicle that has not paid off yet' do
      before { post '/parking', params: valid_attributes }
      before { get "/parking/#{plate}" }

      it 'return valid data' do
        expect(json).not_to be_empty
        expect(json['paid']).to eq(false)
        expect(json['left']).to eq(false)
      end

      it 'tells that the vehicle is still parked' do
        expect(response.body).to match(/Still parked/)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end
    
    context 'when getting an invalid vehicle' do
      let(:invalid_plate) { 'aaa999' }
      before { get "/parking/#{invalid_plate}" }

      it 'returns an error message' do
        expect(response.body)
          .to match(/Couldn't find Park/)
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /parking' do
    let(:plate) { Faker::Base.regexify(/[A-Z]{3}-[0-9]{4}/) }
    let(:valid_attributes) { { plate: plate } }

    context 'when creating a valid parking entry' do
      before { post '/parking', params: valid_attributes }

      it 'creates a parking entry' do
        expect(json['plate']).to eq(plate)
        expect(json['left']).to eq(false)
        expect(json['paid']).to eq(false)
        expect(json['left_in']).to eq(nil)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when creating a parking entry with the same plate when already parked' do
      before { 
        post '/parking', params: valid_attributes
        post '/parking', params: valid_attributes
      }
      
      it 'returns status code 422 - validation error' do
        expect(response).to have_http_status(422)
      end

      it 'returns an error message' do
        expect(response.body)
          .to match(/Validation failed: There is a car already parked with the same plate/)
      end
    end

    context 'when creating an invalid parking entry' do
      before { post '/parking', params: { plate: 'aa000'} }

      it 'returns an error message' do
        expect(response.body)
          .to match(/Validation failed: Plate is invalid/)
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PUT /parking/:id/pay' do
    let(:plate) { Faker::Base.regexify(/[A-Z]{3}-[0-9]{4}/) }
    let(:valid_attributes) { { plate: plate } }

    context 'when paying a parked vehicle' do
      before { post '/parking', params: valid_attributes }
      let(:parking_id) { Park.first.id }
      before { put "/parking/#{parking_id}/pay" }

      it 'updates the record' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when paying an already paid vehicle' do
      before { post '/parking', params: valid_attributes }
      let(:parking_id) { Park.first.id }
      before { put "/parking/#{parking_id}/pay" }
      before { put "/parking/#{parking_id}/pay" }

      it 'returns an error message' do
        expect(response.body)
          .to match(/Parking already paid/)
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end

    context 'when paying an invalid vehicle' do
      let(:invalid_id) { 0 }
      before { put "/parking/#{invalid_id}/pay" }

      it 'returns an error message' do
        expect(response.body)
          .to match(/Couldn't find Park with 'id'/)
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'PUT /parking/:id/out' do
    let(:plate) { Faker::Base.regexify(/[A-Z]{3}-[0-9]{4}/) }
    let(:valid_attributes) { { plate: plate } }

    context 'when leaving a paid vehicle' do
      before { post '/parking', params: valid_attributes }
      let(:parking_id) { Park.first.id }
      before { put "/parking/#{parking_id}/pay" }
      before { put "/parking/#{parking_id}/out" }

      it 'updates the record' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when leaving an unpaid vehicle' do
      before { post '/parking', params: valid_attributes }
      let(:parking_id) { Park.first.id }
      before { put "/parking/#{parking_id}/out" }

      it 'returns an error message' do
        expect(response.body)
          .to match(/Can\'t leave without paying/)
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end

    context 'when leaving a vehicle already gone' do
      before { post '/parking', params: valid_attributes }
      let(:parking_id) { Park.first.id }
      before { put "/parking/#{parking_id}/pay" }
      before { put "/parking/#{parking_id}/out" }
      before { put "/parking/#{parking_id}/out" }

      it 'returns an error message' do
        expect(response.body)
          .to match(/Vehicle already left/)
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end
  end
end