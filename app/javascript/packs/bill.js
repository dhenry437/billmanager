$('#recurringCheck').change(function () {
    if (this.checked) {
        $('#recurring').removeClass('visually-hidden');
        $('#bill_recurring_every').prop('required', true);
    } else {
        $('#recurring').addClass('visually-hidden');
        $('#bill_recurring_every').prop('required', false);
    }
});