import api from '../api';

import { showAlertForError } from './alerts';
import { importFetchedAccounts } from './importer';

export const ANTENNA_FETCH_REQUEST = 'ANTENNA_FETCH_REQUEST';
export const ANTENNA_FETCH_SUCCESS = 'ANTENNA_FETCH_SUCCESS';
export const ANTENNA_FETCH_FAIL    = 'ANTENNA_FETCH_FAIL';

export const ANTENNAS_FETCH_REQUEST = 'ANTENNAS_FETCH_REQUEST';
export const ANTENNAS_FETCH_SUCCESS = 'ANTENNAS_FETCH_SUCCESS';
export const ANTENNAS_FETCH_FAIL    = 'ANTENNAS_FETCH_FAIL';

export const ANTENNA_EDITOR_TITLE_CHANGE = 'ANTENNA_EDITOR_TITLE_CHANGE';
export const ANTENNA_EDITOR_RESET        = 'ANTENNA_EDITOR_RESET';
export const ANTENNA_EDITOR_SETUP        = 'ANTENNA_EDITOR_SETUP';

export const ANTENNA_CREATE_REQUEST = 'ANTENNA_CREATE_REQUEST';
export const ANTENNA_CREATE_SUCCESS = 'ANTENNA_CREATE_SUCCESS';
export const ANTENNA_CREATE_FAIL    = 'ANTENNA_CREATE_FAIL';

export const ANTENNA_UPDATE_REQUEST = 'ANTENNA_UPDATE_REQUEST';
export const ANTENNA_UPDATE_SUCCESS = 'ANTENNA_UPDATE_SUCCESS';
export const ANTENNA_UPDATE_FAIL    = 'ANTENNA_UPDATE_FAIL';

export const ANTENNA_DELETE_REQUEST = 'ANTENNA_DELETE_REQUEST';
export const ANTENNA_DELETE_SUCCESS = 'ANTENNA_DELETE_SUCCESS';
export const ANTENNA_DELETE_FAIL    = 'ANTENNA_DELETE_FAIL';

export const ANTENNA_ACCOUNTS_FETCH_REQUEST = 'ANTENNA_ACCOUNTS_FETCH_REQUEST';
export const ANTENNA_ACCOUNTS_FETCH_SUCCESS = 'ANTENNA_ACCOUNTS_FETCH_SUCCESS';
export const ANTENNA_ACCOUNTS_FETCH_FAIL    = 'ANTENNA_ACCOUNTS_FETCH_FAIL';

export const ANTENNA_EDITOR_SUGGESTIONS_CHANGE = 'ANTENNA_EDITOR_SUGGESTIONS_CHANGE';
export const ANTENNA_EDITOR_SUGGESTIONS_READY  = 'ANTENNA_EDITOR_SUGGESTIONS_READY';
export const ANTENNA_EDITOR_SUGGESTIONS_CLEAR  = 'ANTENNA_EDITOR_SUGGESTIONS_CLEAR';

export const ANTENNA_EDITOR_ADD_REQUEST = 'ANTENNA_EDITOR_ADD_REQUEST';
export const ANTENNA_EDITOR_ADD_SUCCESS = 'ANTENNA_EDITOR_ADD_SUCCESS';
export const ANTENNA_EDITOR_ADD_FAIL    = 'ANTENNA_EDITOR_ADD_FAIL';

export const ANTENNA_EDITOR_REMOVE_REQUEST = 'ANTENNA_EDITOR_REMOVE_REQUEST';
export const ANTENNA_EDITOR_REMOVE_SUCCESS = 'ANTENNA_EDITOR_REMOVE_SUCCESS';
export const ANTENNA_EDITOR_REMOVE_FAIL    = 'ANTENNA_EDITOR_REMOVE_FAIL';

export const ANTENNA_ADDER_RESET = 'ANTENNA_ADDER_RESET';
export const ANTENNA_ADDER_SETUP = 'ANTENNA_ADDER_SETUP';

export const ANTENNA_ADDER_ANTENNAS_FETCH_REQUEST = 'ANTENNA_ADDER_ANTENNAS_FETCH_REQUEST';
export const ANTENNA_ADDER_ANTENNAS_FETCH_SUCCESS = 'ANTENNA_ADDER_ANTENNAS_FETCH_SUCCESS';
export const ANTENNA_ADDER_ANTENNAS_FETCH_FAIL    = 'ANTENNA_ADDER_ANTENNAS_FETCH_FAIL';

export const fetchAntenna = id => (dispatch, getState) => {
  if (getState().getIn(['antennas', id])) {
    return;
  }

  dispatch(fetchAntennaRequest(id));

  api(getState).get(`/api/v1/antennas/${id}`)
    .then(({ data }) => dispatch(fetchAntennaSuccess(data)))
    .catch(err => dispatch(fetchAntennaFail(id, err)));
};

export const fetchAntennaRequest = id => ({
  type: ANTENNA_FETCH_REQUEST,
  id,
});

export const fetchAntennaSuccess = antenna => ({
  type: ANTENNA_FETCH_SUCCESS,
  antenna,
});

export const fetchAntennaFail = (id, error) => ({
  type: ANTENNA_FETCH_FAIL,
  id,
  error,
});

export const fetchAntennas = () => (dispatch, getState) => {
  dispatch(fetchAntennasRequest());

  api(getState).get('/api/v1/antennas')
    .then(({ data }) => dispatch(fetchAntennasSuccess(data)))
    .catch(err => dispatch(fetchAntennasFail(err)));
};

export const fetchAntennasRequest = () => ({
  type: ANTENNAS_FETCH_REQUEST,
});

export const fetchAntennasSuccess = antennas => ({
  type: ANTENNAS_FETCH_SUCCESS,
  antennas,
});

export const fetchAntennasFail = error => ({
  type: ANTENNAS_FETCH_FAIL,
  error,
});

export const submitAntennaEditor = shouldReset => (dispatch, getState) => {
  const antennaId = getState().getIn(['antennaEditor', 'antennaId']);
  const title  = getState().getIn(['antennaEditor', 'title']);

  if (antennaId === null) {
    dispatch(createAntenna(title, shouldReset));
  } else {
    dispatch(updateAntenna(antennaId, title, shouldReset));
  }
};

export const setupAntennaEditor = antennaId => (dispatch, getState) => {
  dispatch({
    type: ANTENNA_EDITOR_SETUP,
    antenna: getState().getIn(['antennas', antennaId]),
  });

  dispatch(fetchAntennaAccounts(antennaId));
};

export const changeAntennaEditorTitle = value => ({
  type: ANTENNA_EDITOR_TITLE_CHANGE,
  value,
});

export const createAntenna = (title, shouldReset) => (dispatch, getState) => {
  dispatch(createAntennaRequest());

  api(getState).post('/api/v1/antennas', { title }).then(({ data }) => {
    dispatch(createAntennaSuccess(data));

    if (shouldReset) {
      dispatch(resetAntennaEditor());
    }
  }).catch(err => dispatch(createAntennaFail(err)));
};

export const createAntennaRequest = () => ({
  type: ANTENNA_CREATE_REQUEST,
});

export const createAntennaSuccess = antenna => ({
  type: ANTENNA_CREATE_SUCCESS,
  antenna,
});

export const createAntennaFail = error => ({
  type: ANTENNA_CREATE_FAIL,
  error,
});

export const updateAntenna = (id, title, shouldReset, list_id, stl, with_media_only, ignore_reblog, insert_feeds) => (dispatch, getState) => {
  dispatch(updateAntennaRequest(id));

  api(getState).put(`/api/v1/antennas/${id}`, { title, list_id, stl, with_media_only, ignore_reblog, insert_feeds }).then(({ data }) => {
    dispatch(updateAntennaSuccess(data));

    if (shouldReset) {
      dispatch(resetAntennaEditor());
    }
  }).catch(err => dispatch(updateAntennaFail(id, err)));
};

export const updateAntennaRequest = id => ({
  type: ANTENNA_UPDATE_REQUEST,
  id,
});

export const updateAntennaSuccess = antenna => ({
  type: ANTENNA_UPDATE_SUCCESS,
  antenna,
});

export const updateAntennaFail = (id, error) => ({
  type: ANTENNA_UPDATE_FAIL,
  id,
  error,
});

export const resetAntennaEditor = () => ({
  type: ANTENNA_EDITOR_RESET,
});

export const deleteAntenna = id => (dispatch, getState) => {
  dispatch(deleteAntennaRequest(id));

  api(getState).delete(`/api/v1/antennas/${id}`)
    .then(() => dispatch(deleteAntennaSuccess(id)))
    .catch(err => dispatch(deleteAntennaFail(id, err)));
};

export const deleteAntennaRequest = id => ({
  type: ANTENNA_DELETE_REQUEST,
  id,
});

export const deleteAntennaSuccess = id => ({
  type: ANTENNA_DELETE_SUCCESS,
  id,
});

export const deleteAntennaFail = (id, error) => ({
  type: ANTENNA_DELETE_FAIL,
  id,
  error,
});

export const fetchAntennaAccounts = antennaId => (dispatch, getState) => {
  dispatch(fetchAntennaAccountsRequest(antennaId));

  api(getState).get(`/api/v1/antennas/${antennaId}/accounts`, { params: { limit: 0 } }).then(({ data }) => {
    dispatch(importFetchedAccounts(data));
    dispatch(fetchAntennaAccountsSuccess(antennaId, data));
  }).catch(err => dispatch(fetchAntennaAccountsFail(antennaId, err)));
};

export const fetchAntennaAccountsRequest = id => ({
  type: ANTENNA_ACCOUNTS_FETCH_REQUEST,
  id,
});

export const fetchAntennaAccountsSuccess = (id, accounts, next) => ({
  type: ANTENNA_ACCOUNTS_FETCH_SUCCESS,
  id,
  accounts,
  next,
});

export const fetchAntennaAccountsFail = (id, error) => ({
  type: ANTENNA_ACCOUNTS_FETCH_FAIL,
  id,
  error,
});

export const fetchAntennaSuggestions = q => (dispatch, getState) => {
  const params = {
    q,
    resolve: false,
  };

  api(getState).get('/api/v1/accounts/search', { params }).then(({ data }) => {
    dispatch(importFetchedAccounts(data));
    dispatch(fetchAntennaSuggestionsReady(q, data));
  }).catch(error => dispatch(showAlertForError(error)));
};

export const fetchAntennaSuggestionsReady = (query, accounts) => ({
  type: ANTENNA_EDITOR_SUGGESTIONS_READY,
  query,
  accounts,
});

export const clearAntennaSuggestions = () => ({
  type: ANTENNA_EDITOR_SUGGESTIONS_CLEAR,
});

export const changeAntennaSuggestions = value => ({
  type: ANTENNA_EDITOR_SUGGESTIONS_CHANGE,
  value,
});

export const addToAntennaEditor = accountId => (dispatch, getState) => {
  dispatch(addToAntenna(getState().getIn(['antennaEditor', 'antennaId']), accountId));
};

export const addToAntenna = (antennaId, accountId) => (dispatch, getState) => {
  dispatch(addToAntennaRequest(antennaId, accountId));

  api(getState).post(`/api/v1/antennas/${antennaId}/accounts`, { account_ids: [accountId] })
    .then(() => dispatch(addToAntennaSuccess(antennaId, accountId)))
    .catch(err => dispatch(addToAntennaFail(antennaId, accountId, err)));
};

export const addToAntennaRequest = (antennaId, accountId) => ({
  type: ANTENNA_EDITOR_ADD_REQUEST,
  antennaId,
  accountId,
});

export const addToAntennaSuccess = (antennaId, accountId) => ({
  type: ANTENNA_EDITOR_ADD_SUCCESS,
  antennaId,
  accountId,
});

export const addToAntennaFail = (antennaId, accountId, error) => ({
  type: ANTENNA_EDITOR_ADD_FAIL,
  antennaId,
  accountId,
  error,
});

export const removeFromAntennaEditor = accountId => (dispatch, getState) => {
  dispatch(removeFromAntenna(getState().getIn(['antennaEditor', 'antennaId']), accountId));
};

export const removeFromAntenna = (antennaId, accountId) => (dispatch, getState) => {
  dispatch(removeFromAntennaRequest(antennaId, accountId));

  api(getState).delete(`/api/v1/antennas/${antennaId}/accounts`, { params: { account_ids: [accountId] } })
    .then(() => dispatch(removeFromAntennaSuccess(antennaId, accountId)))
    .catch(err => dispatch(removeFromAntennaFail(antennaId, accountId, err)));
};

export const removeFromAntennaRequest = (antennaId, accountId) => ({
  type: ANTENNA_EDITOR_REMOVE_REQUEST,
  antennaId,
  accountId,
});

export const removeFromAntennaSuccess = (antennaId, accountId) => ({
  type: ANTENNA_EDITOR_REMOVE_SUCCESS,
  antennaId,
  accountId,
});

export const removeFromAntennaFail = (antennaId, accountId, error) => ({
  type: ANTENNA_EDITOR_REMOVE_FAIL,
  antennaId,
  accountId,
  error,
});

export const resetAntennaAdder = () => ({
  type: ANTENNA_ADDER_RESET,
});

export const setupAntennaAdder = accountId => (dispatch, getState) => {
  dispatch({
    type: ANTENNA_ADDER_SETUP,
    account: getState().getIn(['accounts', accountId]),
  });
  dispatch(fetchAntennas());
  dispatch(fetchAccountAntennas(accountId));
};

export const fetchAccountAntennas = accountId => (dispatch, getState) => {
  dispatch(fetchAccountAntennasRequest(accountId));

  api(getState).get(`/api/v1/accounts/${accountId}/antennas`)
    .then(({ data }) => dispatch(fetchAccountAntennasSuccess(accountId, data)))
    .catch(err => dispatch(fetchAccountAntennasFail(accountId, err)));
};

export const fetchAccountAntennasRequest = id => ({
  type:ANTENNA_ADDER_ANTENNAS_FETCH_REQUEST,
  id,
});

export const fetchAccountAntennasSuccess = (id, antennas) => ({
  type: ANTENNA_ADDER_ANTENNAS_FETCH_SUCCESS,
  id,
  antennas,
});

export const fetchAccountAntennasFail = (id, err) => ({
  type: ANTENNA_ADDER_ANTENNAS_FETCH_FAIL,
  id,
  err,
});

export const addToAntennaAdder = antennaId => (dispatch, getState) => {
  dispatch(addToAntenna(antennaId, getState().getIn(['antennaAdder', 'accountId'])));
};

export const removeFromAntennaAdder = antennaId => (dispatch, getState) => {
  dispatch(removeFromAntenna(antennaId, getState().getIn(['antennaAdder', 'accountId'])));
};

