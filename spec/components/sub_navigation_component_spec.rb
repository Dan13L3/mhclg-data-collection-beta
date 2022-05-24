require "rails_helper"

RSpec.describe SubNavigationComponent, type: :component do
  let(:items) do
    [
      NavigationItemsHelper::NavigationItem.new("Organisations", "/organisations", true),
      NavigationItemsHelper::NavigationItem.new("Users", "/users", false),
      NavigationItemsHelper::NavigationItem.new("Logs ", "/logs", false),
    ]
  end

  context "when the item is 'current' in nav items" do
    it "then that tab appears as selected" do
      result = render_inline(described_class.new(items:))

      expect(result.css('.app-sub-navigation__link[aria-current="page"]').text).to include("Organisations")
    end
  end

  context "when the current page is sub-page" do
    it "highlights the correct tab" do
      navigation_panel = described_class.new(items:)

      expect(navigation_panel).to be_highlighted_item(items[0], "/something-else")
      expect(navigation_panel).not_to be_highlighted_item(items[1], "/something-else")
      expect(navigation_panel).not_to be_highlighted_item(items[2], "/something-else")
    end
  end

  context "when rendering items" do
    it "all of the nav items specified in the items hash are passed to it" do
      result = render_inline(described_class.new(items:))

      expect(result.text).to include("Organisations")
      expect(result.text).to include("Users")
      expect(result.text).to include("Logs")
    end
  end
end
