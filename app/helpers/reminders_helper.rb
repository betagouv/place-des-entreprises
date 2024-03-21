module RemindersHelper
  def build_reminders_card_footer(action, need)
    #  Sans réponse :
    #  - bouton Experts relancés (reminders_action :poke)
    #  Risque abandon :
    #  - Email : Envoyer email last_chance -> Conseillers
    #  - bouton Experts relancés (reminders_action :last_chance)
    #  Refusés :
    #  - Email : Envoyer email échec -> Ets
    #  - bouton Traiter (reminders_action :abandoned)
    html = ""
    html << email_button(action, need) if with_email.include? action
    html << action_button(action, need) if with_action.include? action
    html
  end

  def build_expert_reminders_link(expert)
    current_basket = expert.last_reminder_register.basket
    link = link_to expert.antenne.to_s, reminders_expert_path(expert), title: t('helpers.reminders.link_to_expert_reminders'), data: { turbo: false }
    icon = tag.span(class: "fr-ml-1v reminders-icon #{t(current_basket, scope: 'reminders.experts.scopes.icon')}", title: t('helpers.reminders.present_in_basket', basket: t(current_basket, scope: 'reminders.experts.scopes.name')), 'aria-hidden': 'true')
    link + icon
  end

  private

  def with_email
    %i[last_chance refused]
  end

  def with_last_chance_email
    %i[last_chance]
  end

  def with_abandoned_email
    %i[refused]
  end

  def with_action
    %i[poke last_chance refused quo_match]
  end

  def action_button(action, need)
    button_to t(action, scope: 'reminders.needs.scopes.mark_done'), reminders_actions_path, { params: { need_id: need.id, category: action }, method: :post, class: 'fr-btn btn-green' }
  end

  # Todo : probable possibilité de factoriser aussi ici
  def email_button(action, need)
    button = if with_last_chance_email.include? action
      form_builder(send_last_chance_email_reminders_need_path(need), t('reminders.send_last_chance_email'), need)
    elsif with_abandoned_email.include? action
      form_builder(send_failure_email_reminders_need_path(need), t('reminders.send_failure_email'), need)
    end
    tag.div(button, id: "reminder-email-#{need.id}",)
  end

  def p_tag_builder(text)
    tag.p(text, class: 'fr-btn fr-btn--secondary fr-fi-checkbox-circle-line fr-btn--icon-left fr-btn-green fr-mr-2v')
  end

  def form_builder(path, text, need, form_options = {})
    form_with(model: need, url: path, method: :post, **form_options) do |f|
      f.submit text, class: 'fr-btn fr-btn--secondary fr-mr-2v'
    end.html_safe
  end
end
