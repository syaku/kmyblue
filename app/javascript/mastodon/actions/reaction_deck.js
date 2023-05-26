import api from '../api';

export const REACTION_DECK_FETCH_REQUEST = 'REACTION_DECK_FETCH_REQUEST';
export const REACTION_DECK_FETCH_SUCCESS = 'REACTION_DECK_FETCH_SUCCESS';
export const REACTION_DECK_FETCH_FAIL    = 'REACTION_DECK_FETCH_FAIL';

export const REACTION_DECK_UPDATE_REQUEST = 'REACTION_DECK_UPDATE_REQUEST';
export const REACTION_DECK_UPDATE_SUCCESS = 'REACTION_DECK_UPDATE_SUCCESS';
export const REACTION_DECK_UPDATE_FAIL = 'REACTION_DECK_UPDATE_FAIL';

export const REACTION_DECK_REMOVE_REQUEST = 'REACTION_DECK_REMOVE_REQUEST';
export const REACTION_DECK_REMOVE_SUCCESS = 'REACTION_DECK_REMOVE_SUCCESS';
export const REACTION_DECK_REMOVE_FAIL = 'REACTION_DECK_REMOVE_FAIL';

export function fetchReactionDeck() {
  return (dispatch, getState) => {
    dispatch(fetchReactionDeckRequest());

    api(getState).get('/api/v1/reaction_deck').then(response => {
      dispatch(fetchReactionDeckSuccess(response.data));
    }).catch(error => {
      dispatch(fetchReactionDeckFail(error));
    });
  };
}

export function fetchReactionDeckRequest() {
  return {
    type: REACTION_DECK_FETCH_REQUEST,
    skipLoading: true,
  };
}

export function fetchReactionDeckSuccess(emojis) {
  return {
    type: REACTION_DECK_FETCH_SUCCESS,
    emojis,
    skipLoading: true,
  };
}

export function fetchReactionDeckFail(error) {
  return {
    type: REACTION_DECK_FETCH_FAIL,
    error,
    skipLoading: true,
  };
}

export function updateReactionDeck(emojis) {
  return (dispatch, getState) => {
    dispatch(updateReactionDeckRequest());

    api(getState).post('/api/v1/reaction_deck', { emojis }).then(response => {
      dispatch(updateReactionDeckSuccess(response.data));
    }).catch(error => {
      dispatch(updateReactionDeckFail(error));
    });
  };
}

export function updateReactionDeckRequest() {
  return {
    type: REACTION_DECK_UPDATE_REQUEST,
    skipLoading: true,
  };
}

export function updateReactionDeckSuccess(emojis) {
  return {
    type: REACTION_DECK_UPDATE_SUCCESS,
    emojis,
    skipLoading: true,
  };
}

export function updateReactionDeckFail(error) {
  return {
    type: REACTION_DECK_UPDATE_FAIL,
    error,
    skipLoading: true,
  };
}

export function removeReactionDeck(id) {
  return (dispatch, getState) => {
    dispatch(removeReactionDeckRequest());

    api(getState).post('/api/v1/remove_reaction_deck', { emojis: [{ id }] }).then(response => {
      dispatch(removeReactionDeckSuccess(response.data));
    }).catch(error => {
      dispatch(removeReactionDeckFail(error));
    });
  };
}

export function removeReactionDeckRequest() {
  return {
    type: REACTION_DECK_REMOVE_REQUEST,
    skipLoading: true,
  };
}

export function removeReactionDeckSuccess(emojis) {
  return {
    type: REACTION_DECK_REMOVE_SUCCESS,
    emojis,
    skipLoading: true,
  };
}

export function removeReactionDeckFail(error) {
  return {
    type: REACTION_DECK_REMOVE_FAIL,
    error,
    skipLoading: true,
  };
}
