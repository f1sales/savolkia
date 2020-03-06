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

    if lead.source.name.downcase.include?('facebook') && lead.message.downcase.include?('são_paulo_-_ipiranga')
      customer = lead.customer

      HTTP.post(
        'https://savolkiasp.f1sales.org/integrations/leads',
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

    if lead.source.name.downcase.include?('facebook') && lead.message.downcase.include?('são_bernardo')
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

