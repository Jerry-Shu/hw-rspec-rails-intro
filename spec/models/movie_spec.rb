require 'rails_helper'

describe Movie do
  describe '.find_in_tmdb' do
    let(:fake_response) { { 'results' => [{ 'title' => 'Manhunter', 'overview' => 'A thriller.', 'release_date' => '1986-08-15' }] }.to_json }

    it 'calls TMDb with the correct URL' do
      allow(Faraday).to receive(:get).and_return(double('response', body: fake_response))

      response = Movie.find_in_tmdb('Manhunter')

      expect(response.first[:title]).to eq('Manhunter')
      expect(response.first[:overview]).to eq('A thriller.')
      expect(response.first[:release_date]).to eq(Date.parse('1986-08-15'))
    end
  end
end
