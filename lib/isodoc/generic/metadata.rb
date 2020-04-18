require "isodoc"

module IsoDoc
  module Generic

    class Metadata < IsoDoc::Metadata
      def initialize(lang, script, labels)
        super
        here = File.dirname(__FILE__)
        default_logo_path = File.expand_path(File.join(here, "html", "logo.jpg"))
        set(:logo, baselocation(configuration.logo_path) || default_logo_path)
      end

      class << self
        attr_accessor :_file
      end

      def self.inherited( k )
        k._file = caller_locations.first.absolute_path
      end

      def baselocation(loc)
        return nil if loc.nil?
        File.expand_path(File.join(File.dirname(self.class::_file || __FILE__), "..", "..", "..", loc))
      end

      def configuration
        Metanorma::Generic.configuration
      end

      def author(isoxml, _out)
        super
        tc = isoxml.at(ns("//bibdata/ext/editorialgroup/committee"))
        set(:tc, tc.text) if tc
      end

      def stage_abbr(status)
        return super unless configuration.stage_abbreviations
        Hash(configuration.stage_abbreviations).dig(status)
      end

      def unpublished(status)
        stages = configuration&.published_stages || ["published"]
        !(Array(stages).map { |m| m.downcase }.include? status.downcase)
      end
    end
  end
end