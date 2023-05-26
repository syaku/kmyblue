import PropTypes from 'prop-types';

import { defineMessages, injectIntl } from 'react-intl';

import { Helmet } from 'react-helmet';

import { Map as ImmutableMap } from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';
import { createSelector } from 'reselect';

import ColumnHeader from 'mastodon/components/column_header';
import LoadingIndicator from 'mastodon/components/loading_indicator';
import ScrollableList from 'mastodon/components/scrollable_list';
import Column from 'mastodon/features/ui/components/column';

import ReactionEmoji from './components/reaction_emoji';


const DECK_SIZE = 16;

const customEmojiMap = createSelector([state => state.get('custom_emojis')], items => items.reduce((map, emoji) => map.set(emoji.get('shortcode'), emoji), ImmutableMap()));

const messages = defineMessages({
  refresh: { id: 'refresh', defaultMessage: 'Refresh' },
  heading: { id: 'column.reaction_deck', defaultMessage: 'Reaction deck' },
});

const mapStateToProps = (state, props) => ({
  accountIds: state.getIn(['user_lists', 'favourited_by', props.params.statusId]),
  deck: state.get('reaction_deck'),
  emojiMap: customEmojiMap(state),
});

class ReactionDeck extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    deck: ImmutablePropTypes.list,
    emojiMap: ImmutablePropTypes.map,
    multiColumn: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { intl, deck, emojiMap, multiColumn } = this.props;

    if (!deck) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }


    return (
      <Column bindToDocument={!multiColumn}>
        <ColumnHeader
          icon='smile-o'
          title={intl.formatMessage(messages.heading)}
          multiColumn={multiColumn}
          showBackButton
        />

          <ScrollableList
            scrollKey='reaction_deck'
            bindToDocument={!multiColumn}
          >
            {[...Array(DECK_SIZE).keys()].map(emojiId =>
              <ReactionEmoji key={emojiId} emojiMap={emojiMap} emojiId={emojiId} />
            )}
          </ScrollableList>

        <Helmet>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(ReactionDeck));
