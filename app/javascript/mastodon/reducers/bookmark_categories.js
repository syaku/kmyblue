import { Map as ImmutableMap, fromJS, OrderedSet as ImmutableOrderedSet } from 'immutable';

import {
  BOOKMARK_CATEGORY_FETCH_SUCCESS,
  BOOKMARK_CATEGORY_FETCH_FAIL,
  BOOKMARK_CATEGORIES_FETCH_SUCCESS,
  BOOKMARK_CATEGORY_CREATE_SUCCESS,
  BOOKMARK_CATEGORY_UPDATE_SUCCESS,
  BOOKMARK_CATEGORY_DELETE_SUCCESS,
  BOOKMARK_CATEGORY_STATUSES_FETCH_REQUEST,
  BOOKMARK_CATEGORY_STATUSES_FETCH_SUCCESS,
  BOOKMARK_CATEGORY_STATUSES_FETCH_FAIL,
  BOOKMARK_CATEGORY_STATUSES_EXPAND_REQUEST,
  BOOKMARK_CATEGORY_STATUSES_EXPAND_SUCCESS,
  BOOKMARK_CATEGORY_STATUSES_EXPAND_FAIL,
} from '../actions/bookmark_categories';
import {
  UNBOOKMARK_SUCCESS,
} from '../actions/interactions';

const initialState = ImmutableMap();

const normalizeBookmarkCategory = (state, category) => state.set(category.id, fromJS(category));

const normalizeBookmarkCategories = (state, bookmarkCategories) => {
  bookmarkCategories.forEach(bookmarkCategory => {
    state = normalizeBookmarkCategory(state, bookmarkCategory);
  });

  return state;
};

const normalizeBookmarkCategoryStatuses = (state, bookmarkCategoryId, statuses, next) => {
  return state.update(bookmarkCategoryId, listMap => listMap.withMutations(map => {
    map.set('next', next);
    map.set('loaded', true);
    map.set('isLoading', false);
    map.set('items', ImmutableOrderedSet(statuses.map(item => item.id)));
  }));
};

const appendToBookmarkCategoryStatuses = (state, bookmarkCategoryId, statuses, next) => {
  return state.update(bookmarkCategoryId, listMap => listMap.withMutations(map => {
    map.set('next', next);
    map.set('isLoading', false);
    map.set('items', map.get('items').union(statuses.map(item => item.id)));
  }));
};

const removeStatusFromAllBookmarkCategories = (state, status) => {
  state.toList().forEach((bookmarkCategory) => {
    state = state.updateIn([bookmarkCategory.get('id'), 'items'], items => items.delete(status.get('id')));
  });
  return state;
};

export default function bookmarkCategories(state = initialState, action) {
  switch(action.type) {
  case BOOKMARK_CATEGORY_FETCH_SUCCESS:
  case BOOKMARK_CATEGORY_CREATE_SUCCESS:
  case BOOKMARK_CATEGORY_UPDATE_SUCCESS:
    return normalizeBookmarkCategory(state, action.bookmarkCategory);
  case BOOKMARK_CATEGORIES_FETCH_SUCCESS:
    return normalizeBookmarkCategories(state, action.bookmarkCategories);
  case BOOKMARK_CATEGORY_DELETE_SUCCESS:
  case BOOKMARK_CATEGORY_FETCH_FAIL:
    return state.set(action.id, false);
  case BOOKMARK_CATEGORY_STATUSES_FETCH_REQUEST:
  case BOOKMARK_CATEGORY_STATUSES_EXPAND_REQUEST:
    return state.setIn([action.id, 'isLoading'], true);
  case BOOKMARK_CATEGORY_STATUSES_FETCH_FAIL:
  case BOOKMARK_CATEGORY_STATUSES_EXPAND_FAIL:
    return state.setIn([action.id, 'isLoading'], false);
  case BOOKMARK_CATEGORY_STATUSES_FETCH_SUCCESS:
    return normalizeBookmarkCategoryStatuses(state, action.id, action.statuses, action.next);
  case BOOKMARK_CATEGORY_STATUSES_EXPAND_SUCCESS:
    return appendToBookmarkCategoryStatuses(state, action.id, action.statuses, action.next);
  case UNBOOKMARK_SUCCESS:
    return removeStatusFromAllBookmarkCategories(state, action.status);
  default:
    return state;
  }
}
