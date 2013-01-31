module TasksHelper
  
  def task_item_link(task_item)
    style = task_item.completed? ? "text-decoration: line-through;" : ""
    content_tag(:span, link_to(task_item.name, task_item.url), :style => style)
  end
end