import PropTypes from 'prop-types';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { debounce } from 'lodash';

import { expandBookmarkCategoryStatuses, fetchBookmarkCategory, fetchBookmarkCategoryStatuses } from 'mastodon/actions/bookmark_categories';
import { addColumn, removeColumn, moveColumn } from 'mastodon/actions/columns';
import ColumnHeader from 'mastodon/components/column_header';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import StatusList from 'mastodon/components/status_list';
import BundleColumnError from 'mastodon/features/ui/components/bundle_column_error';
import Column from 'mastodon/features/ui/components/column';
import { getBookmarkCategoryStatusList } from 'mastodon/selectors';

const messages = defineMessages({
  heading: { id: 'column.bookmarks', defaultMessage: 'Bookmarks' },
});

const mapStateToProps = (state, { params }) => ({
  bookmarkCategory: state.getIn(['bookmark_categories', params.id]),
  statusIds: getBookmarkCategoryStatusList(state, params.id),
  isLoading: state.getIn(['bookmark_categories', params.id, 'isLoading'], true),
  hasMore: !!state.getIn(['bookmark_categories', params.id, 'next']),
});

class BookmarkCategoryStatuses extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    statusIds: ImmutablePropTypes.list.isRequired,
    bookmarkCategory: PropTypes.oneOfType([ImmutablePropTypes.map, PropTypes.bool]),
    intl: PropTypes.object.isRequired,
    columnId: PropTypes.string,
    multiColumn: PropTypes.bool,
    hasMore: PropTypes.bool,
    isLoading: PropTypes.bool,
  };

  UNSAFE_componentWillMount () {
    this.props.dispatch(fetchBookmarkCategory(this.props.params.id));
    this.props.dispatch(fetchBookmarkCategoryStatuses(this.props.params.id));
  }

  handlePin = () => {
    const { columnId, dispatch } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('BOOKMARKS_EX', {}));
    }
  };

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  };

  handleHeaderClick = () => {
    this.column.scrollTop();
  };

  setRef = c => {
    this.column = c;
  };

  handleLoadMore = debounce(() => {
    this.props.dispatch(expandBookmarkCategoryStatuses());
  }, 300, { leading: true });

  render () {
    const { intl, bookmarkCategory, statusIds, columnId, multiColumn, hasMore, isLoading } = this.props;
    const pinned = !!columnId;

    if (typeof bookmarkCategory === 'undefined') {
      return (
        <Column>
          <div className='scrollable'>
            <LoadingIndicator />
          </div>
        </Column>
      );
    } else if (bookmarkCategory === false) {
      return (
        <BundleColumnError multiColumn={multiColumn} errorType='routing' />
      );
    }

    const emptyMessage = <FormattedMessage id='empty_column.bookmarked_statuses' defaultMessage="You don't have any bookmarked posts yet. When you bookmark one, it will show up here." />;

    return (
      <Column bindToDocument={!multiColumn} ref={this.setRef} label={intl.formatMessage(messages.heading)}>
        <ColumnHeader
          icon='bookmark'
          title={bookmarkCategory.get('title')}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          multiColumn={multiColumn}
        />

        <StatusList
          trackScroll={!pinned}
          statusIds={statusIds}
          scrollKey={`bookmark_ex_statuses-${columnId}`}
          hasMore={hasMore}
          isLoading={isLoading}
          onLoadMore={this.handleLoadMore}
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
        />

        <Helmet>
          <title>{intl.formatMessage(messages.heading)}</title>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(BookmarkCategoryStatuses));
