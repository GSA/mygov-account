module TasksHelper
  
  def task_item_link(task_item)
    style = task_item.completed? ? "text-decoration: line-through;" : ""
    name = task_item.url? ? link_to(task_item.name, task_item.url, { :target => "_blank" }) : task_item.name
    content_tag(:span, name, :style => style)
  end
end