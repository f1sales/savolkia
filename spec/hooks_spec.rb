require File.expand_path '../spec_helper.rb', __FILE__
require 'ostruct'
require "f1sales_custom/hooks"

RSpec.describe F1SalesCustom::Hooks::Lead do

  let(:source) do
    source = OpenStruct.new
    source.name = 'Facebook - Savol Kia'
    source
  end

  let(:customer) do
    customer = OpenStruct.new
    customer.name = 'Marcio'
    customer.phone = '1198788899'
    customer.email = 'marcio@f1sales.com.br'

    customer
  end

  let(:product) do
    product = OpenStruct.new
    product.name = 'Some product'

    product
  end

  context 'when is to Santo André' do
    let(:lead) do
      lead = OpenStruct.new
      lead.message = 'como_deseja_ser_contatado?: e-mail: escolha_a_unidade_savol_kia: savol_kia_santo_andré'
      lead.source = source
      lead.customer = customer
      lead.product = product

      lead
    end

    it 'returns source name' do
      expect(described_class.switch_source(lead)).to eq(lead.source.name)
    end
  end

  context 'when is to Toyota Praia' do
    let(:source_toyta_praia) do
      source = OpenStruct.new
      source.name = 'Facebook - Savol Toyota'
      source
    end

    let(:lead) do
      lead = OpenStruct.new
      lead.message = 'como_deseja_ser_contatado?: e-mail'
      lead.source = source_toyta_praia
      lead.customer = customer
      lead.product = product

      lead
    end

    let(:call_url){ "https://savoltoyotapraia.f1sales.org/integrations/leads" }

    let(:lead_payload) do
      {
        lead: {
          message: lead.message,
          customer: {
            name: customer.name,
            email: customer.email,
            phone: customer.phone,
          },
          product: {
            name: product.name
          },
          source: {
            name: source_toyta_praia.name
          }
        }
      }
    end

    before do
      ENV['STORE_ID'] = 'savolkia'
      stub_request(:post, call_url).
        with(body: lead_payload.to_json).to_return(status: 200, body: "", headers: {})
    end

    it 'returns nil' do
      expect(described_class.switch_source(lead)).to be_nil
    end

    it 'post to toyota praia' do
      described_class.switch_source(lead) rescue nil
      expect(WebMock).to have_requested(:post, call_url).
        with(body: lead_payload)
    end
  end

  context 'when is to SJC' do
    let(:source_sjc) do
      source = OpenStruct.new
      source.name = 'Facebook - Savol Kia São José dos Campos'
      source
    end

    let(:lead) do
      lead = OpenStruct.new
      lead.message = 'como_deseja_ser_contatado?: e-mail'
      lead.source = source_sjc
      lead.customer = customer
      lead.product = product

      lead
    end

    let(:call_url){ "https://savolkiasjc.f1sales.org/integrations/leads" }

    let(:lead_payload) do
      {
        lead: {
          message: lead.message,
          customer: {
            name: customer.name,
            email: customer.email,
            phone: customer.phone,
          },
          product: {
            name: product.name
          },
          source: {
            name: source_sjc.name
          }
        }
      }
    end

    before do
      stub_request(:post, call_url).
        with(body: lead_payload.to_json).to_return(status: 200, body: "", headers: {})
    end

    it 'returns nil' do
      expect(described_class.switch_source(lead)).to be_nil
    end

    it 'post to sjc' do
      described_class.switch_source(lead) rescue nil
      expect(WebMock).to have_requested(:post, call_url).
        with(body: lead_payload)
    end
  end

  # context 'when is to SBC' do
  #
  #   let(:lead) do
  #     lead = OpenStruct.new
  #     lead.message = 'como_deseja_ser_contatado?: e-mail: escolha_a_unidade_savol_kia: são_bernardo'
  #     lead.source = source
  #     lead.customer = customer
  #     lead.product = product
  #
  #     lead
  #   end
  #
  #   let(:call_url){ "https://savolkiasbc.f1sales.org/integrations/leads" }
  #
  #   let(:lead_payload) do
  #     {
  #       lead: {
  #         message: lead.message,
  #         customer: {
  #           name: customer.name,
  #           email: customer.email,
  #           phone: customer.phone,
  #         },
  #         product: {
  #           name: product.name
  #         },
  #         source: {
  #           name: source.name
  #         }
  #       }
  #     }
  #   end
  #
  #   before do
  #     stub_request(:post, call_url).
  #       with(body: lead_payload.to_json).to_return(status: 200, body: "", headers: {})
  #   end
  #
  #   it 'returns nil' do
  #     expect(described_class.switch_source(lead)).to be_nil
  #   end
  #
  #   it 'post to sbc' do
  #     described_class.switch_source(lead) rescue nil
  #     expect(WebMock).to have_requested(:post, call_url).
  #       with(body: lead_payload)
  #   end
  #
  # end

  # context 'when is to SP' do
  #
  #   let(:lead) do
  #     lead = OpenStruct.new
  #     lead.message = 'como_deseja_ser_contatado?: e-mail: escolha_a_unidade_savol_kia: são_paulo_-_ipiranga'
  #     lead.source = source
  #     lead.customer = customer
  #     lead.product = product
  #
  #     lead
  #   end
  #
  #
  #   let(:call_url){ "https://savolkiasp.f1sales.org/integrations/leads" }
  #
  #   let(:lead_payload) do
  #     {
  #       lead: {
  #         message: lead.message,
  #         customer: {
  #           name: customer.name,
  #           email: customer.email,
  #           phone: customer.phone,
  #         },
  #         product: {
  #           name: product.name
  #         },
  #         source: {
  #           name: source.name
  #         }
  #       }
  #     }
  #   end
  #
  #   before do
  #     stub_request(:post, call_url).
  #       with(body: lead_payload.to_json).to_return(status: 200, body: "", headers: {})
  #   end
  #
  #   it 'returns nil' do
  #     expect(described_class.switch_source(lead)).to be_nil
  #   end
  #
  #   it 'post to sp' do
  #     described_class.switch_source(lead) rescue nil
  #     expect(WebMock).to have_requested(:post, call_url).
  #       with(body: lead_payload)
  #   end


    # it 'sets Facebook São Paulo store source' do
    #   expect(described_class.switch_source(lead)).to eq(source.name + ' - São Paulo')
    # end

  # end
end
