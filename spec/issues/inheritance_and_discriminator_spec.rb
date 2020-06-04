# frozen_string_literal: true

require 'spec_helper'

describe 'Inheritance and Discriminator' do
  before :all do
    module InheritanceTest
      module Entities
        # example from https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md#models-with-polymorphism-supports
        class Pet < Grape::Entity
          expose :type, documentation: {
            type: 'string',
            is_discriminator: true,
            required: true
          }
          expose :name, documentation: {
            type: 'string',
            required: true
          }

        end

        class Cat < Pet
          expose :huntingSkill, documentation: {
            type: "string",
            description: "The measured skill for hunting",
            default: "lazy",
            enum: [
              "clueless",
              "lazy",
              "adventurous",
              "aggressive"
            ]
          }
        end
      end
      class NameApi < Grape::API
        add_swagger_documentation models: [Entities::Pet]
      end
    end
  end


  context "Parent model" do

    let(:app) { InheritanceTest::NameApi }

    subject do
      get '/swagger_doc'
      JSON.parse(last_response.body)['definitions']
    end

    specify {
      subject['InheritanceTest::Entities::Pet'].key?('discriminator')
      subject['InheritanceTest::Entities::Pet']['discriminator'] = 'type'
    }
  end
end
