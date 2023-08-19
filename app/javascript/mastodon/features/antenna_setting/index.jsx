import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage, defineMessages, injectIntl } from 'react-intl';

import { Helmet } from 'react-helmet';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import Select, { NonceProvider } from 'react-select';
import Toggle from 'react-toggle';

import { fetchAntenna, deleteAntenna, updateAntenna } from 'mastodon/actions/antennas';
import { addColumn, removeColumn, moveColumn } from 'mastodon/actions/columns';
import { fetchLists } from 'mastodon/actions/lists';
import { openModal } from 'mastodon/actions/modal';
import Button from 'mastodon/components/button';
import Column from 'mastodon/components/column';
import ColumnHeader from 'mastodon/components/column_header';
import { Icon }  from 'mastodon/components/icon';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import BundleColumnError from 'mastodon/features/ui/components/bundle_column_error';

const messages = defineMessages({
  deleteMessage: { id: 'confirmations.delete_antenna.message', defaultMessage: 'Are you sure you want to permanently delete this antenna?' },
  deleteConfirm: { id: 'confirmations.delete_antenna.confirm', defaultMessage: 'Delete' },
  editAccounts: { id: 'antennas.edit_accounts', defaultMessage: 'Edit accounts' },
  noOptions: { id: 'antennas.select.no_options_message', defaultMessage: 'Empty lists' },
  placeholder: { id: 'antennas.select.placeholder', defaultMessage: 'Select list' },
});

const mapStateToProps = (state, props) => ({
  antenna: state.getIn(['antennas', props.params.id]),
  lists: state.get('lists'),
});

class AntennaSetting extends PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    columnId: PropTypes.string,
    multiColumn: PropTypes.bool,
    antenna: PropTypes.oneOfType([ImmutablePropTypes.map, PropTypes.bool]),
    lists: ImmutablePropTypes.list,
    intl: PropTypes.object.isRequired,
  };

  handlePin = () => {
    const { columnId, dispatch } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('ANTENNA', { id: this.props.params.id }));
      this.context.router.history.push('/');
    }
  };

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  };

  handleHeaderClick = () => {
    this.column.scrollTop();
  };

  componentDidMount () {
    const { dispatch } = this.props;
    const { id } = this.props.params;

    dispatch(fetchAntenna(id));
    dispatch(fetchLists());
  }

  UNSAFE_componentWillReceiveProps (nextProps) {
    const { dispatch } = this.props;
    const { id } = nextProps.params;

    if (id !== this.props.params.id) {
      dispatch(fetchAntenna(id));
    }
  }

  setRef = c => {
    this.column = c;
  };

  handleEditClick = () => {
    this.props.dispatch(openModal({
      modalType: 'ANTENNA_EDITOR',
      modalProps: { antennaId: this.props.params.id },
    }));
  };

  handleEditAntennaClick = () => {
    window.open(`/antennas/${this.props.params.id}/edit`, '_blank');
  }

  handleDeleteClick = () => {
    const { dispatch, columnId, intl } = this.props;
    const { id } = this.props.params;

    dispatch(openModal({
      modalType: 'CONFIRM',
      modalProps: {
        message: intl.formatMessage(messages.deleteMessage),
        confirm: intl.formatMessage(messages.deleteConfirm),
        onConfirm: () => {
          dispatch(deleteAntenna(id));

          if (columnId) {
            dispatch(removeColumn(columnId));
          } else {
            this.context.router.history.push('/antennasw');
          }
        },
      },
    }));
  };

  onStlToggle = ({ target }) => {
    const { dispatch } = this.props;
    const { id } = this.props.params;
    dispatch(updateAntenna(id, undefined, false, undefined, target.checked, undefined, undefined, undefined));
  };

  onMediaOnlyToggle = ({ target }) => {
    const { dispatch } = this.props;
    const { id } = this.props.params;
    dispatch(updateAntenna(id, undefined, false, undefined, undefined, target.checked, undefined, undefined));
  };

  onIgnoreReblogToggle = ({ target }) => {
    const { dispatch } = this.props;
    const { id } = this.props.params;
    dispatch(updateAntenna(id, undefined, false, undefined, undefined, undefined, target.checked, undefined));
  };

  onNoInsertFeedsToggle = ({ target }) => {
    const { dispatch } = this.props;
    const { id } = this.props.params;
    dispatch(updateAntenna(id, undefined, false, undefined, undefined, undefined, undefined, target.checked));
  };

  onSelect = value => {
    const { dispatch } = this.props;
    const { id } = this.props.params;
    dispatch(updateAntenna(id, undefined, false, value.value, undefined, undefined, undefined, undefined));
  };

  noOptionsMessage = () => this.props.intl.formatMessage(messages.noOptions);

  render () {
    const { columnId, multiColumn, antenna, lists, intl } = this.props;
    const { id } = this.props.params;
    const pinned = !!columnId;
    const title  = antenna ? antenna.get('title') : id;
    const isStl = antenna ? antenna.get('stl') : undefined;
    const isMediaOnly = antenna ? antenna.get('with_media_only') : undefined;
    const isIgnoreReblog = antenna ? antenna.get('ignore_reblog') : undefined;
    const isInsertFeeds = antenna ? antenna.get('insert_feeds') : undefined;

    if (typeof antenna === 'undefined') {
      return (
        <Column>
          <div className='scrollable'>
            <LoadingIndicator />
          </div>
        </Column>
      );
    } else if (antenna === false) {
      return (
        <BundleColumnError multiColumn={multiColumn} errorType='routing' />
      );
    }

    let columnSettings;
    if (!isStl) {
      columnSettings = (
        <>
          <div className='setting-toggle'>
            <Toggle id={`antenna-${id}-mediaonly`} defaultChecked={isMediaOnly} onChange={this.onMediaOnlyToggle} />
            <label htmlFor={`antenna-${id}-mediaonly`} className='setting-toggle__label'>
              <FormattedMessage id='antennas.media_only' defaultMessage='Media only' />
            </label>
          </div>

          <div className='setting-toggle'>
            <Toggle id={`antenna-${id}-ignorereblog`} defaultChecked={isIgnoreReblog} onChange={this.onIgnoreReblogToggle} />
            <label htmlFor={`antenna-${id}-ignorereblog`} className='setting-toggle__label'>
              <FormattedMessage id='antennas.ignore_reblog' defaultMessage='Exclude boosts' />
            </label>
          </div>
        </>
      )
    }

    let stlAlert;
    if (isStl) {
      stlAlert = (
        <div className='antenna-setting'>
          <p><FormattedMessage id='antennas.in_stl_mode' defaultMessage='This antenna is in STL mode.' /></p>
        </div>
      );
    }

    const listOptions = lists.toArray().map((list) => {
      return { value: list[1].get('id'), label: list[1].get('title') }
    });

    return (
      <Column bindToDocument={!multiColumn} ref={this.setRef} label={title}>
        <ColumnHeader
          icon='wifi'
          title={title}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          multiColumn={multiColumn}
        >
          <div className='column-settings__row column-header__links'>
            <button type='button' className='text-btn column-header__setting-btn' tabIndex={0} onClick={this.handleEditAntennaClick}>
              <Icon id='pencil' /> <FormattedMessage id='anntennas.edit' defaultMessage='Edit antenna' />
            </button>

            <button type='button' className='text-btn column-header__setting-btn' tabIndex={0} onClick={this.handleDeleteClick}>
              <Icon id='trash' /> <FormattedMessage id='antennas.delete' defaultMessage='Delete antenna' />
            </button>
          </div>

          <div className='setting-toggle'>
            <Toggle id={`antenna-${id}-stl`} defaultChecked={isStl} onChange={this.onStlToggle} />
            <label htmlFor={`antenna-${id}-stl`} className='setting-toggle__label'>
              <FormattedMessage id='antennas.stl' defaultMessage='STL mode' />
            </label>
          </div>

          <div className='setting-toggle'>
            <Toggle id={`antenna-${id}-noinsertfeeds`} defaultChecked={isInsertFeeds} onChange={this.onNoInsertFeedsToggle} />
            <label htmlFor={`antenna-${id}-noinsertfeeds`} className='setting-toggle__label'>
              <FormattedMessage id='antennas.insert_feeds' defaultMessage='Insert to feeds' />
            </label>
          </div>

          {columnSettings}
        </ColumnHeader>

        {stlAlert}
        <div className='antenna-setting'>
          {isInsertFeeds && (
            <>
              {antenna.get('list') ? (
                <p><FormattedMessage id='antennas.related_list' defaultMessage='This antenna is related to {listTitle}.' values={{ listTitle: antenna.getIn(['list', 'title']) }} /></p>
              ) : (
                <p><FormattedMessage id='antennas.not_related_list' defaultMessage='This antenna is not related list. Posts will appear in home timeline. Open edit page to set list.' /></p>
              )}

              <NonceProvider nonce={document.querySelector('meta[name=style-nonce]').content} cacheKey='lists'>
                <Select
                  value={{ value: antenna.getIn(['list', 'id']), label: antenna.getIn(['list', 'title']) }}
                  options={listOptions}
                  noOptionsMessage={this.noOptionsMessage}
                  onChange={this.onSelect}
                  className='column-select__container'
                  classNamePrefix='column-select'
                  name='lists'
                  placeholder={this.props.intl.formatMessage(messages.placeholder)}
                  defaultOptions
                />
              </NonceProvider>
            </>
          )}

          {!isStl && (
            <>
              <h3><FormattedMessage id='antennas.accounts' defaultMessage='{count} accounts' values={{ count: antenna.get('accounts_count') }} /></h3>
              <Button text={intl.formatMessage(messages.editAccounts)} onClick={this.handleEditClick} />

              <h3><FormattedMessage id='antennas.domains' defaultMessage='{count} domains' values={{ count: antenna.get('domains_count') }} /></h3>
              <h3><FormattedMessage id='antennas.tags' defaultMessage='{count} tags' values={{ count: antenna.get('tags_count') }} /></h3>
              <h3><FormattedMessage id='antennas.keywords' defaultMessage='{count} keywords' values={{ count: antenna.get('keywords_count') }} /></h3>
            </>
          )}
        </div>

        <Helmet>
          <title>{title}</title>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(AntennaSetting));
