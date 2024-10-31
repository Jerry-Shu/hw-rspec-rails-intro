require 'rails_helper'

describe Movie do
  describe '.find_in_tmdb' do
    let(:fake_response) { { 'results' => [{ 'title' => 'Manhunter', 'overview' => 'A thriller.', 'release_date' => '1986-08-15' }] }.to_json }

    it 'calls TMDb with the correct URL' do
      # Stub the response from Faraday
      allow(Faraday).to receive(:get).and_return(double('response', body: fake_response))

      # Call the method with test data
      response = Movie.find_in_tmdb('Manhunter')

      # Verify the data structure
      expect(response.first[:title]).to eq('Manhunter')
      expect(response.first[:overview]).to eq('A thriller.')
      expect(response.first[:release_date]).to eq(Date.parse('1986-08-15'))
    end
  end
end
