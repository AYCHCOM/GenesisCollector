require 'nokogiri'
require 'core_ext/try'

module GenesisCollector
  class LshwParser
    attr_reader :doc

    def initialize(doc)
      @doc = Nokogiri::XML(doc)
    end

    def memories
      @memories ||= doc.xpath("//node[@class='memory']/*[@id]").map do |memory|
        mem_size = memory.at_xpath('.//size')
        {
          size: mem_size.nil? ? 0 : mem_size.text.to_i,
          description: memory.at_xpath('.//description').text,
          bank: memory.at_xpath('.//physid').text.to_i,
          slot: memory.at_xpath('.//slot').try(:text),
          product: memory.at_xpath('.//product').try(:text),
          vendor_name: memory.at_xpath('.//vendor').try(:text)
        }
      end
    end

    def network_interfaces
      @network_interfaces ||= doc.xpath("//node[@class='network']").map do |network_interface|
        {
          name: network_interface.at_xpath('.//logicalname').try(:text),
          description: network_interface.at_xpath('.//description').try(:text),
          mac_address: network_interface.at_xpath('.//serial').try(:text),
          product: network_interface.at_xpath('.//product').try(:text),
          vendor_name: network_interface.at_xpath('.//vendor').try(:text),
          driver: network_interface.at_xpath(".//configuration//setting[@id='driver']/@value").try(:text),
          driver_version: network_interface.at_xpath(".//configuration//setting[@id='driverversion']/@value").try(:text),
          duplex: network_interface.at_xpath(".//configuration//setting[@id='duplex']/@value").try(:text),
          link_type: network_interface.at_xpath(".//configuration//setting[@id='port']/@value").try(:text)
        }
      end
    end
  end
end
