# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Infrastructure Registry' do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }

  before do
    sign_in(user)
    project.add_maintainer(user)
  end

  context 'when feature is not available' do
    before do
      stub_feature_flags(infrastructure_registry_page: false)
    end

    it 'gives 404' do
      visit_project_infrastructure_registry

      expect(status_code).to eq(404)
    end
  end

  context 'when feature is available', :js do
    before do
      visit_project_infrastructure_registry
    end

    context 'when there are packages' do
      let_it_be(:terraform_module) { create(:terraform_module_package, project: project, created_at: 1.day.ago, version: '1.0.0') }
      let_it_be(:terraform_module2) { create(:terraform_module_package, project: project, created_at: 2.days.ago, version: '2.0.0') }
      let_it_be(:packages) { [terraform_module, terraform_module2] }

      it_behaves_like 'packages list'

      context 'deleting a package' do
        let_it_be(:project) { create(:project) }
        let_it_be(:terraform_module) { create(:terraform_module_package, project: project) }

        it 'allows you to delete a module', :aggregate_failures do
          # this is still using the package copy in the UI too
          click_button('Remove package')
          click_button('Delete package')

          expect(page).to have_content 'Package deleted successfully'
          expect(page).not_to have_content(terraform_module.name)
        end
      end
    end

    it 'displays the empty message' do
      expect(page).to have_content('You have no Terraform modules in your project')
    end
  end

  def visit_project_infrastructure_registry
    visit project_infrastructure_registry_index_path(project)
  end
end
