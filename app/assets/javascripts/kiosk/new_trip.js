function viewSequence ($) {
  var els = $('*[data-index]')
    , firstEl;
  if(els.length < 1) return;

  function changeFrames(e, dir) {
    var nextIndex = els.index(els.filter('.current')) + dir
      , nextEl    = $(els[nextIndex]);

    els.addClass('hidden').removeClass('current');
    nextEl.removeClass('hidden').addClass('current');
    updateMap();
    showNavButton();

    if (e) e.preventDefault();
  }

  function progress (e) {
    changeFrames(e, 1);
  }

  function goBack (e) {
    changeFrames(e, -1);
  }

  function updateMap() {
    if (els.filter('.current').hasClass('location-from')) {
      // Show the google map and re-calculate size. Have to do show() before reset to ensure
      // that leaflet code knows the size of the map, so it can calculate size correctly.
      $('#trip_map').show();
      resetMapView(); // If you don't do this, map will be the size of a postage stamp!
    }
  }

  function showNavButton () {
    if (els.filter('.current').hasClass('js-hide-nav-button')) {
      $('.next-footer-container').addClass('hidden');
    } else {
      $('.next-footer-container').removeClass('hidden');
    }
  }

  if (window.location.hash == '#back') {
    firstEl = els.last();
  } else {
    firstEl = els.first();
  }

  els.addClass('hidden');
  firstEl.removeClass('hidden').addClass('current');
  showNavButton();

  $(document).on('click', '.js-progress-sequence', progress);

  $(document).on('click', '.next-step-btn', function () {
    if (els.filter('.current').is(els.last())) {
      $('.js-trip-wizard-form').submit();
    } else {
      progress();
    }
  });

  $(document).on('click', '.back-button a', function (e) {
    if (els.filter('.current').is(els.first())) {
      $(e.target)
    } else {
      goBack(e);
    }
  });
};

function zoom_to_marker(marker) {
  if (marker) {
    //setMapToBounds();
    setMapToMarkerBounds(marker);
    selectMarker(marker);
  }
}

jQuery(function ($) {
  if ($('.js-trip-wizard-form').length < 1) return;
  viewSequence($);

  $('.js-trip-wizard-form input').each(function () {
    $input = $(this);
    var result = $input.prop('name').match(/trip_proxy\[(.*)\]/);

    if (result && NewTrip.read()[result[1]]) {
      $input.val(NewTrip.read()[result[1]]);
    }
  });

  $('.js-trip-wizard-form').on('ajax:complete', NewTrip.stepCompleteHandler);
});
