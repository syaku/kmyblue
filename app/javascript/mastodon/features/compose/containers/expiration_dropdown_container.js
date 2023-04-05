import { connect } from 'react-redux';
import ExpirationDropdown from '../components/expiration_dropdown';
import { openModal, closeModal } from '../../../actions/modal';
import { isUserTouching } from '../../../is_mobile';

const mapStateToProps = state => ({
  value: state.getIn(['compose', 'privacy']),
});

const mapDispatchToProps = (dispatch, { onPickExpiration }) => ({

  onChange (value) {
    if (onPickExpiration) {
      onPickExpiration(value);
    }
  },

  isUserTouching,
  onModalOpen: props => dispatch(openModal('ACTIONS', props)),
  onModalClose: () => dispatch(closeModal()),

});

export default connect(mapStateToProps, mapDispatchToProps)(ExpirationDropdown);
