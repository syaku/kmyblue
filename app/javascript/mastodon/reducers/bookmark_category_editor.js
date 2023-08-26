import { Map as ImmutableMap, List as ImmutableList } from 'immutable';

import {
  BOOKMARK_CATEGORY_CREATE_REQUEST,
  BOOKMARK_CATEGORY_CREATE_FAIL,
  BOOKMARK_CATEGORY_CREATE_SUCCESS,
  BOOKMARK_CATEGORY_UPDATE_REQUEST,
  BOOKMARK_CATEGORY_UPDATE_FAIL,
  BOOKMARK_CATEGORY_UPDATE_SUCCESS,
  BOOKMARK_CATEGORY_EDITOR_RESET,
  BOOKMARK_CATEGORY_EDITOR_SETUP,
  BOOKMARK_CATEGORY_EDITOR_TITLE_CHANGE,
  BOOKMARK_CATEGORY_EDITOR_ADD_SUCCESS,
  BOOKMARK_CATEGORY_EDITOR_REMOVE_SUCCESS,
} from '../actions/bookmark_categories';

const initialState = ImmutableMap({
  bookmaryCategoryId: null,
  isSubmitting: false,
  isChanged: false,
  title: '',
  isExclusive: false,

  statuses: ImmutableMap({
    items: ImmutableList(),
    loaded: false,
    isLoading: false,
  }),

  suggestions: ImmutableMap({
    value: '',
    items: ImmutableList(),
  }),
});

export default function bookmaryCategoryEditorReducer(state = initialState, action) {
  switch(action.type) {
  case BOOKMARK_CATEGORY_EDITOR_RESET:
    return initialState;
  case BOOKMARK_CATEGORY_EDITOR_SETUP:
    return state.withMutations(map => {
      map.set('bookmaryCategoryId', action.bookmaryCategory.get('id'));
      map.set('title', action.bookmaryCategory.get('title'));
      map.set('isExclusive', action.bookmaryCategory.get('is_exclusive'));
      map.set('isSubmitting', false);
    });
  case BOOKMARK_CATEGORY_EDITOR_TITLE_CHANGE:
    return state.withMutations(map => {
      map.set('title', action.value);
      map.set('isChanged', true);
    });
  case BOOKMARK_CATEGORY_CREATE_REQUEST:
  case BOOKMARK_CATEGORY_UPDATE_REQUEST:
    return state.withMutations(map => {
      map.set('isSubmitting', true);
      map.set('isChanged', false);
    });
  case BOOKMARK_CATEGORY_CREATE_FAIL:
  case BOOKMARK_CATEGORY_UPDATE_FAIL:
    return state.set('isSubmitting', false);
  case BOOKMARK_CATEGORY_CREATE_SUCCESS:
  case BOOKMARK_CATEGORY_UPDATE_SUCCESS:
    return state.withMutations(map => {
      map.set('isSubmitting', false);
      map.set('bookmaryCategoryId', action.bookmaryCategory.id);
    });
  case BOOKMARK_CATEGORY_EDITOR_ADD_SUCCESS:
    return state.updateIn(['accounts', 'items'], bookmaryCategory => bookmaryCategory.unshift(action.accountId));
  case BOOKMARK_CATEGORY_EDITOR_REMOVE_SUCCESS:
    return state.updateIn(['accounts', 'items'], bookmaryCategory => bookmaryCategory.filterNot(item => item === action.accountId));
  default:
    return state;
  }
}
