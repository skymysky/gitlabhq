# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Integrations::Ewm do
  describe 'Associations' do
    it { is_expected.to belong_to :project }
    it { is_expected.to have_one :service_hook }
  end

  describe 'Validations' do
    context 'when service is active' do
      before do
        subject.active = true
      end

      it { is_expected.to validate_presence_of(:project_url) }
      it { is_expected.to validate_presence_of(:issues_url) }
      it { is_expected.to validate_presence_of(:new_issue_url) }
      it_behaves_like 'issue tracker service URL attribute', :project_url
      it_behaves_like 'issue tracker service URL attribute', :issues_url
      it_behaves_like 'issue tracker service URL attribute', :new_issue_url
    end

    context 'when service is inactive' do
      before do
        subject.active = false
      end

      it { is_expected.not_to validate_presence_of(:project_url) }
      it { is_expected.not_to validate_presence_of(:issues_url) }
      it { is_expected.not_to validate_presence_of(:new_issue_url) }
    end
  end

  describe "ReferencePatternValidation" do
    it "extracts bug" do
      expect(described_class.reference_pattern.match("This is bug 123")[:issue]).to eq("bug 123")
    end

    it "extracts task" do
      expect(described_class.reference_pattern.match("This is task 123.")[:issue]).to eq("task 123")
    end

    it "extracts work item" do
      expect(described_class.reference_pattern.match("This is work item 123 now")[:issue]).to eq("work item 123")
    end

    it "extracts workitem" do
      expect(described_class.reference_pattern.match("workitem 123 at the beginning")[:issue]).to eq("workitem 123")
    end

    it "extracts defect" do
      expect(described_class.reference_pattern.match("This is defect 123 defect")[:issue]).to eq("defect 123")
    end

    it "extracts rtcwi" do
      expect(described_class.reference_pattern.match("This is rtcwi 123")[:issue]).to eq("rtcwi 123")
    end
  end
end
