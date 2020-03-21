require "savolkia/version"

require "f1sales_custom/parser"
require "f1sales_custom/source"
require "f1sales_custom/hooks"
require "f1sales_helpers"
require "json"

module Savolkia
  class Error < StandardError; end

  class F1SalesCustom::Hooks::Lead 

    def self.switch_source(lead)

      # Facebook - Savol Kia São José dos Campos
      if ENV['STORE_ID'] != 'savolkiasjc' && lead.source.name.include?('Facebook - Savol Kia São José dos Campos')
        customer = lead.customer

        HTTP.post(
          'https://savolkiasjc.f1sales.org/integrations/leads',
          json: {
            lead: {
              message: lead.message,
              customer: {
                name: customer.name,
                email: customer.email,
                phone: customer.phone,
              },
              product: {
                name: lead.product.name
              },
              source: {
                name: lead.source.name
              }
            }
          },
        )

        return nil

      end

      if ENV['STORE_ID'] == 'savolkiasp'
        store_id = "savolkiasbc"

        if rand(0..1) == 0
          store_id = "savolkia"
        end

        HTTP.post(
          "https://#{store_id}.f1sales.org/integrations/leads",
          json: {
            lead: {
              message: lead.message,
              customer: {
                name: customer.name,
                email: customer.email,
                phone: customer.phone,
              },
              product: {
                name: lead.product.name
              },
              source: {
                name: lead.source.name
              }
            }
          },
        )

        return nil
      end

      # if ENV['STORE_ID'] != 'savolkiasp' &&
      #     lead.source.name.downcase.include?('facebook') &&
      #     (lead.message.downcase.include?('são_paulo_-_ipiranga') ||
      #       lead.message.downcase.include?('savol_kia_sp') ||
      #       lead.message.downcase.include?('savol_kia_são_paulo'))
      #   customer = lead.customer
      #
      #   HTTP.post(
      #     'https://savolkiasp.f1sales.org/integrations/leads',
      #     json: {
      #       lead: {
      #         message: lead.message,
      #         customer: {
      #           name: customer.name,
      #           email: customer.email,
      #           phone: customer.phone,
      #         },
      #         product: {
      #           name: lead.product.name
      #         },
      #         source: {
      #           name: lead.source.name
      #         }
      #       }
      #     },
      #   )
      #
      #   return nil
      #
      # end
      #
      if ENV['STORE_ID'] != 'savolkiasbc' &&
          lead.source.name.downcase.include?('facebook') &&
          (lead.message.downcase.include?('são_bernardo') || lead.message.downcase.include?('savol_kia_são_bernardo'))
        customer = lead.customer

        HTTP.post(
          'https://savolkiasbc.f1sales.org/integrations/leads',
          json: {
            lead: {
              message: lead.message,
              customer: {
                name: customer.name,
                email: customer.email,
                phone: customer.phone,
              },
              product: {
                name: lead.product.name
              },
              source: {
                name: lead.source.name
              }
            }
          },
        )

        return nil
      end

      return lead.source.name
    end
  end

  class F1SalesCustom::Email::Source 
    def self.all
      [
        {
          email_id: 'website',
          name: 'Website'
        },
      ]
    end
  end

  class F1SalesCustom::Email::Parser
    def parse
      parsed_email = JSON.parse(@email.body.gsub('!@#', '')) rescue nil

      if parsed_email.nil?
        parsed_email = @email.body.colons_to_hash(/(Telefone|Nome|Mensagem|E-mail|CPF).*?:/, false) unless parsed_email

        {
          source: {
            name: F1SalesCustom::Email::Source.all[0][:name],
          },
          customer: {
            name: parsed_email['nome'],
            phone: parsed_email['telefone'],
            email: parsed_email['email'],
          },
          product: @email.subject,
          message: parsed_email['mensagem'],
          description: "",
        }
      else

        {
          source: {
            name: F1SalesCustom::Email::Source.all[0][:name],
          },
          customer: {
            name: parsed_email['Nome'],
            phone: parsed_email['Telefone'].to_s,
            email: parsed_email['E-mail'],
          },
          product: "#{parsed_email['Veículo'].strip} #{parsed_email['Placa']}",
          message: parsed_email['Descricao'],
          description: "Preço #{parsed_email['Preço']}",
        }
      end
    end
  end
end

