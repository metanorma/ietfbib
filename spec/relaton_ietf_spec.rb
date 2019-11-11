# frozen_string_literal: true

require "relaton_ietf"
require "date"

RSpec.describe RelatonIetf do
  it "has a version number" do
    expect(RelatonIetf::VERSION).not_to be nil
  end

  it "get RFC document" do
    VCR.use_cassette "rfc_8341" do
      item = RelatonIetf::IetfBibliography.search "RFC 8341"
      expect(item).to be_instance_of RelatonIetf::IetfBibliographicItem
      file = "spec/examples/bib_item.xml"
      xml = item.to_xml bibdata: true
      File.write file, xml unless File.exist? file
      expect(xml).to be_equivalent_to File.read(file).sub(
        %r{<fetched>\d\d\d\d-\d\d-\d\d</fetched>}, "<fetched>#{Date.today}</fetched>"
      )
    end
  end

  it "get internet draft document" do
    VCR.use_cassette "i_d_burger_xcon_mmodels" do
      item = RelatonIetf::IetfBibliography.search "I-D.-burger-xcon-mmodels"
      expect(item).to be_instance_of RelatonIetf::IetfBibliographicItem
      file = "spec/examples/i_d_bib_item.xml"
      File.write file, item.to_xml unless File.exist? file
      expect(item.to_xml).to be_equivalent_to File.read(file).sub(
        %r{<fetched>\d\d\d\d-\d\d-\d\d</fetched>}, "<fetched>#{Date.today}</fetched>"
      )
    end
  end

  it "get WC3 document" do
    VCR.use_cassette "w3c_cr_cdr_20070718" do
      item = RelatonIetf::IetfBibliography.search "W3C CR-CDR-20070718"
      expect(item).to be_instance_of RelatonIetf::IetfBibliographicItem
    end
  end

  it "get WC3 document form the second page" do
    VCR.use_cassette "w3c_cr_rdf_schema" do
      item = RelatonIetf::IetfBibliography.search "W3C CR-rdf-schema"
      expect(item).to be_instance_of RelatonIetf::IetfBibliographicItem
    end
  end

  it "get ANSI document" do
    VCR.use_cassette "ansi_t1_102_1007" do
      item = RelatonIetf::IetfBibliography.search "ANSI T1-102.1987"
      expect(item).to be_instance_of RelatonIetf::IetfBibliographicItem
    end
  end

  it "get 3GPP document" do
    VCR.use_cassette "3gpp_01_01" do
      item = RelatonIetf::IetfBibliography.search "3GPP 01.01"
      expect(item).to be_instance_of RelatonIetf::IetfBibliographicItem
    end
  end

  it "get IEEE document" do
    VCR.use_cassette "ieee_730_2014" do
      item = RelatonIetf::IetfBibliography.search "IEEE 730_2014"
      expect(item).to be_instance_of RelatonIetf::IetfBibliographicItem
    end
  end

  it "get best current practise" do
    VCR.use_cassette "bcp_47" do
      item = RelatonIetf::IetfBibliography.get "BCP 47"
      expect(item).to be_instance_of RelatonIetf::IetfBibliographicItem
      file = "spec/examples/bcp_47.xml"
      xml = item.to_xml bibdata: true
      File.write file, xml unless File.exist? file
      expect(xml).to be_equivalent_to File.read(file).sub(
        %r{<fetched>\d\d\d\d-\d\d-\d\d</fetched>}, "<fetched>#{Date.today}</fetched>"
      )
    end
  end

  it "deals with extraneous prefix" do
    expect do
      RelatonIetf::IetfBibliography.get "CN 8341"
    end.to raise_error RelatonBib::RequestError
  end

  it "deals with non-existent document" do
    VCR.use_cassette "non_existed_doc" do
      expect do
        RelatonIetf::IetfBibliography.search "RFC 08341"
      end.to raise_error RelatonBib::RequestError
    end
  end

  context "create RelatonIetf::IetfBibliographicItem from xml" do
    it "RFC" do
      xml = File.read "spec/examples/bib_item.xml"
      item = RelatonIetf::XMLParser.from_xml xml
      expect(item).to be_instance_of RelatonIetf::IetfBibliographicItem
      expect(item.to_xml bibdata: true).to be_equivalent_to xml
    end

    it "BCP" do
      xml = File.read "spec/examples/bcp_47.xml"
      item = RelatonIetf::XMLParser.from_xml xml
      expect(item).to be_instance_of RelatonIetf::IetfBibliographicItem
      expect(item.to_xml bibdata: true).to be_equivalent_to xml
    end
  end
end
