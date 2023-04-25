import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { injectIntl } from 'react-intl';
import { setupAntennaAdder, resetAntennaAdder } from '../../actions/antennas';
import { createSelector } from 'reselect';
import Antenna from './components/antenna';
import Account from './components/account';
// hack

const getOrderedAntennas = createSelector([state => state.get('antennas')], antennas => {
  if (!antennas) {
    return antennas;
  }

  return antennas.toList().filter(item => !!item).sort((a, b) => a.get('title').localeCompare(b.get('title')));
});

const mapStateToProps = state => ({
  antennaIds: getOrderedAntennas(state).map(antenna=>antenna.get('id')),
});

const mapDispatchToProps = dispatch => ({
  onInitialize: accountId => dispatch(setupAntennaAdder(accountId)),
  onReset: () => dispatch(resetAntennaAdder()),
});

class AntennaAdder extends ImmutablePureComponent {

  static propTypes = {
    accountId: PropTypes.string.isRequired,
    onClose: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    onInitialize: PropTypes.func.isRequired,
    onReset: PropTypes.func.isRequired,
    antennaIds: ImmutablePropTypes.list.isRequired,
  };

  componentDidMount () {
    const { onInitialize, accountId } = this.props;
    onInitialize(accountId);
  }

  componentWillUnmount () {
    const { onReset } = this.props;
    onReset();
  }

  render () {
    const { accountId, antennaIds } = this.props;

    return (
      <div className='modal-root__modal list-adder'>
        <div className='list-adder__account'>
          <Account accountId={accountId} />
        </div>

        <div className='list-adder__lists'>
          {antennaIds.map(AntennaId => <Antenna key={AntennaId} antennaId={AntennaId} />)}
        </div>
      </div>
    );
  }

}

export default connect(mapStateToProps, mapDispatchToProps)(injectIntl(AntennaAdder));
