import { connect } from 'react-redux';
import TextIconButton from '../components/text_icon_button';
import { changeComposeMarkdown } from '../../../actions/compose';
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  marked: { id: 'compose_form.markdown.marked', defaultMessage: 'Markdown is enabled' },
  unmarked: { id: 'compose_form.markdown.unmarked', defaultMessage: 'Markdown is disabled' },
});

const mapStateToProps = (state, { intl }) => ({
  label: 'MD',
  title: intl.formatMessage(state.getIn(['compose', 'markdown']) ? messages.marked : messages.unmarked),
  active: state.getIn(['compose', 'markdown']),
  ariaControls: 'cw-markdown-input',
});

const mapDispatchToProps = dispatch => ({

  onClick () {
    dispatch(changeComposeMarkdown());
  },

});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(TextIconButton));
