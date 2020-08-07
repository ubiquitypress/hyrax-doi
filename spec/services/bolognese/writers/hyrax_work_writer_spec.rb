# frozen_string_literal: true
require 'rails_helper'

describe Bolognese::Writers::HyraxWorkWriter do
  let(:model_class) do
    Class.new(GenericWork) do
      include Hyrax::DOI::DOIBehavior

      # Defined here for resourceType
      def self.name
        "WorkWithDOI"
      end
    end
  end
  let(:work) { model_class.create(attributes) }
  let(:attributes) do
    {
      title: [title],
      creator: [creator],
      publisher: [publisher],
      description: [description],
      doi: doi
    }
  end
  let(:title) { 'Moomin' }
  let(:creator) { 'Tove Jansson' }
  let(:publisher) { 'Schildts' }
  let(:description) { 'Swedish comic about the adventures of the residents of Moominvalley.' }
  let(:doi) { '10.18130/v3-k4an-w022' }
  let(:metadata_class) do
    Class.new(Bolognese::Metadata) do
      include Bolognese::Readers::HyraxWorkReader
      include Bolognese::Writers::HyraxWorkWriter
    end
  end

  before do
    stub_const("WorkWithDOI", model_class)
  end

  context 'roundtrips' do
    subject(:new_hyrax_work) { metadata.hyrax_work }
    let(:input) { work.attributes.merge(has_model: work.has_model.first).to_json }
    let(:metadata) { metadata_class.new(input: input, from: 'hyrax_work') }

    it 'creates a work of the proper type' do
      expect(new_hyrax_work).to be_a WorkWithDOI
    end

    it 'correctly populates the work' do
      expect(new_hyrax_work.title).to eq [title]
      expect(new_hyrax_work.creator).to eq [creator]
      expect(new_hyrax_work.publisher).to eq [publisher]
      expect(new_hyrax_work.description).to eq [description]
      expect(new_hyrax_work.doi).to eq doi
    end
  end
end