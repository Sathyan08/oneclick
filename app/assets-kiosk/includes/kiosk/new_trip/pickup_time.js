function setupDatePickerForKiosk (field, startDate) {
    if (!startDate) startDate = new Date;

    $('#trip-date')
        .datepicker()
        .on("dateChange", function(e) {
            $(field).val(Date.format(e.date, "mm/dd/yyyy"));
        }).data('calendar')
        .setStartDate(startDate);

    //CLick Tadaaapicker buttons(now hidden) when you click the outside buttons.
    var datePrev = $('#date-arrow-prev');
    datePrev.on('click', function() {
        $('th.month.prev').click();
    });

    var dateNext = $('#date-arrow-next');
    dateNext.on('click', function() {
        $('th.month.next').click();
    });

    $('#trip-date').data('calendar').mbShow();
}

jQuery(function($) {
    if (!$('.js-trip-wizard-form').hasClass('js-pickup-time-wizard-step')) return;

    NewTrip.timepickerInit('#trip_proxy_outbound_trip_time', '#timepicker-one');
    setupDatePickerForKiosk('#trip_proxy_outbound_trip_date');

    // $('.combobox').combobox({ force_match: false });

    function toggleArriveDepart(currentValue) {
        var timeSection = $('#trip-time');

        if (currentValue === 'Departing at') {
            //change the label to arriving
            timeSection.children('label').html('Arriving at');
            $('#trip_proxy_arrive_depart').val('Arriving By');
            //change the dropdown selected state...
        } else {
            //change the label to departing
            timeSection.children('label').html('Departing at');
            $('#trip_proxy_arrive_depart').val('Departing At');
            //toggle the arriving/departing state
        }
    }

    //TOGGLE THE ARRIVE/DEPART STATE
    $('#arrive-depart-toggle').on('click', function() {
        var timeSection = $('#trip-time'),
            timeLabel = timeSection.children('label').text();

        toggleArriveDepart(timeLabel);
    });

    if (NewTrip.read().arrive_depart) {
        var inverseValue;

        if (NewTrip.read().arrive_depart === 'Arriving By') {
            inverseValue = 'Departing at';
        } else {
            inverseValue = 'Arriving at';
        }

        toggleArriveDepart(inverseValue);
    }
});