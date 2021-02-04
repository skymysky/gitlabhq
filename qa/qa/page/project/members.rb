# frozen_string_literal: true

module QA
  module Page
    module Project
      class Members < Page::Base
        include QA::Page::Component::Select2

        view 'app/views/shared/members/_invite_member.html.haml' do
          element :member_select_field
          element :invite_member_button
        end

        view 'app/views/projects/project_members/index.html.haml' do
          element :invite_group_tab
          element :groups_list_tab
        end

        view 'app/views/shared/members/_invite_group.html.haml' do
          element :group_select_field
          element :invite_group_button
        end

        view 'app/assets/javascripts/pages/projects/project_members/index.js' do
          element :group_row
        end

        view 'app/assets/javascripts/members/components/action_buttons/remove_group_link_button.vue' do
          element :delete_group_access_link
        end

        view 'app/assets/javascripts/members/components/modals/remove_group_link_modal.vue' do
          element :remove_group_link_modal_content
        end

        def select_group(group_name)
          click_element :group_select_field
          search_and_select(group_name)
        end

        def invite_group(group_name)
          click_element :invite_group_tab
          select_group(group_name)
          click_element :invite_group_button
        end

        def add_member(username)
          click_element :member_select_field
          search_and_select username
          click_element :invite_member_button
        end

        def remove_group(group_name)
          click_element :invite_group_tab
          click_element :groups_list_tab

          within_element(:group_row, text: group_name) do
            click_element :delete_group_access_link
          end

          within_element(:remove_group_link_modal_content) do
            click_button 'Remove group'
          end
        end
      end
    end
  end
end
