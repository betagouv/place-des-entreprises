module StatusHelper
  STATUS_COLORS = {
    diagnosis_not_complete: 'grey-blue',
    sent_to_no_one: 'grey-blue',
    quo: 'grey-blue',
    not_for_me: 'red',
    taking_care: 'tilleul',
    done: 'green',
    done_no_help: 'orange',
    done_not_reachable: 'blue-dark'
  }

  STATUS_ICONS = {
    diagnosis_not_complete: %w[],
    sent_to_no_one: %w[],
    quo: %w[ri-question-mark],
    not_for_me: %w[ri-close-line],
    taking_care: %w[ri-loader-2-line],
    done: %w[ri-check-line],
    done_no_help: %w[ri-check-line],
    done_not_reachable: %w[ri-check-line]
  }

  EXPERTS_ICONS = {
    quo: %w[ri-user-line],
    not_for_me: %w[ri-user-unfollow-line],
    taking_care: %w[ri-user-search-line],
    done: %w[ri-user-follow-line],
    done_no_help: %w[ri-user-follow-line],
    done_not_reachable: %w[ri-user-follow-line],
    additional: %w[ri-user-search-line]
  }

  STATUS_CONTENT = %i[done done_no_help done_not_reachable]

  def admin_match_actions_buttons(match)
    allowed_actions = match.allowed_new_status

    form_with(model: match, url: match_path(match), class: 'menu admin-match-actions') do |f|
      allowed_actions.map do |new_status|
        title = Match.human_attribute_value(:status, new_status, context: :action)
        classes = %w[fr-btn] << "btn-#{status_color(new_status)}"
        f.button :submit, name: :status, value: new_status, class: classes.join(' ') do
          title
        end
      end.join.html_safe
    end
  end

  def status_label(need_or_match, length = :short)
    status = need_or_match.status
    title = need_or_match.human_attribute_value(:status, context: length)
    classes = %w[label] << status_color(status)
    tag.div(class: classes.join(' ')) do
      status_icon(status) + title
    end
  end

  def status_icon(status)
    classes = ['icon'] + STATUS_ICONS[status.to_sym]
    tag.span(class: classes.join(' '), aria: { hidden: "true" })
  end

  def expert_status_icon(match)
    classes = []
    classes << if match.additional_match?
      EXPERTS_ICONS[:additional]
    else
      EXPERTS_ICONS[match.status.to_sym]
    end
    classes << status_color(match.status)
    tag.span('', class: classes.join(' '), aria: { hidden: "true" })
  end

  def status_color(status)
    STATUS_COLORS[status.to_sym]
  end
end
