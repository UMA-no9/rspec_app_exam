require 'rails_helper'

RSpec.describe 'Task', type: :system do
  let(:task) { create(:task) }

  describe 'Task一覧' do
    context '正常系' do
      it '一覧ページにアクセスした場合、Taskが表示されること' do
        visit project_tasks_path(task.project)
        expect(page).to have_content task.title
        expect(Task.count).to eq 1
        expect(current_path).to eq project_tasks_path(task.project)
      end

      it 'Project詳細からTask一覧ページにアクセスした場合、Taskが表示されること' do
        visit project_path(task.project)
        within_window(window_opened_by { click_link 'View Todos' }) do
          expect(current_path).to eq project_tasks_path(task.project)
          expect(page).to have_content task.title
          expect(Task.count).to eq 1
          expect(current_path).to eq project_tasks_path(task.project)
        end
      end
    end
  end

  describe 'Task新規作成' do
    context '正常系' do
      it 'Taskが新規作成されること' do
        visit project_tasks_path(task.project)
        click_link 'New Task'
        fill_in 'Title', with: 'test'
        expect { click_button 'Create Task' }.to change { Task.count }.by(1)
        expect(page).to have_content('Task was successfully created.')
        expect(current_path).to eq "/projects/1/tasks/#{task.id + 1}"
      end
    end
  end

  describe 'Task詳細' do
    context '正常系' do
      it 'Taskが表示されること' do
        visit project_task_path(task.project, task)
        expect(page).to have_content(task.title)
        expect(page).to have_content(task.status)
        expect(page).to have_content(task.deadline.strftime('%Y-%m-%d %H:%M'))
        expect(current_path).to eq project_task_path(task.project, task)
      end
    end
  end

  describe 'Task編集' do
    context '正常系' do
      it 'Taskを編集した場合、一覧画面で編集後の内容が表示されること' do
        visit edit_project_task_path(task.project, task)
        fill_in 'Deadline', with: task.deadline
        click_button 'Update Task'
        click_link 'Back'
        expect(find('.task_list')).to have_content(task.deadline.strftime('%-m/%d %-H:%M'))
        expect(current_path).to eq project_tasks_path(task.project)
      end

      it 'ステータスを完了にした場合、Taskの完了日に今日の日付が登録されること' do
        visit edit_project_task_path(task.project, task)
        select 'done', from: 'Status'
        click_button 'Update Task'
        expect(page).to have_content('done')
        expect(page).to have_content(Time.current.strftime('%Y-%m-%d'))
        expect(current_path).to eq project_task_path(task.project, task)
      end

      it '既にステータスが完了のタスクのステータスを変更した場合、Taskの完了日が更新されないこと' do
        task = create(:task, :completion_task)
        visit edit_project_task_path(task.project, task)
        select 'todo', from: 'Status'
        click_button 'Update Task'
        expect(page).to have_content('todo')
        expect(page).not_to have_content(Time.current.strftime('%Y-%m-%d'))
        expect(current_path).to eq project_task_path(task.project, task)
      end
    end
  end

  describe 'Task削除' do
    let!(:task) { create(:task) }

    context '正常系' do
      it 'Taskが削除されること' do
        visit project_tasks_path(task.project)
        page.accept_confirm { click_link 'Destroy' }
        expect(".task_list").not_to have_content task.title
        expect { visit current_path }.to change { Task.count }.by (-1)
        expect(current_path).to eq project_tasks_path(task.project)
      end
    end
  end
end
