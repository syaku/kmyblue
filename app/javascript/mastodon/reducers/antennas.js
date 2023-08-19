import { Map as ImmutableMap, fromJS } from 'immutable';

import {
  ANTENNA_FETCH_SUCCESS,
  ANTENNA_FETCH_FAIL,
  ANTENNAS_FETCH_SUCCESS,
  ANTENNA_CREATE_SUCCESS,
  ANTENNA_UPDATE_SUCCESS,
  ANTENNA_DELETE_SUCCESS,
  ANTENNA_EDITOR_ADD_SUCCESS,
  ANTENNA_EDITOR_REMOVE_SUCCESS,
} from '../actions/antennas';

const initialState = ImmutableMap();

const normalizeAntenna = (state, antenna) => state.set(antenna.id, fromJS(antenna));

const normalizeAntennas = (state, antennas) => {
  antennas.forEach(antenna => {
    state = normalizeAntenna(state, antenna);
  });

  return state;
};

export default function antennas(state = initialState, action) {
  switch(action.type) {
  case ANTENNA_FETCH_SUCCESS:
  case ANTENNA_CREATE_SUCCESS:
  case ANTENNA_UPDATE_SUCCESS:
    return normalizeAntenna(state, action.antenna);
  case ANTENNAS_FETCH_SUCCESS:
    return normalizeAntennas(state, action.antennas);
  case ANTENNA_DELETE_SUCCESS:
  case ANTENNA_FETCH_FAIL:
    return state.set(action.id, false);
  case ANTENNA_EDITOR_ADD_SUCCESS:
    return state.setIn([action.antennaId, 'accounts_count'], state.getIn([action.antennaId, 'accounts_count']) + 1);
  case ANTENNA_EDITOR_REMOVE_SUCCESS:
    return state.setIn([action.antennaId, 'accounts_count'], state.getIn([action.antennaId, 'accounts_count']) - 1);
  default:
    return state;
  }
}
