Bpro = {};

Bpro.utils = {};
Bpro.utils.makeAjax = null;
Bpro.utils.formValidator = null;
Bpro.utils.formSerializer = null;
Bpro.utils.formDeSerializer = null;

Bpro.utils.jsonDeserializer = null;

Bpro.events = {};
Bpro.events.callbacks = { onLoaded: {} };
Bpro.events.onLoaded = null;
Bpro.events.forceCallOnLoaded = null;

Bpro.oneTimeKeystore = null;

Bpro.hashcode = null;

Bpro.utils.makeAjax = function(url, method, dataType, data, callbacks) {
  callbacks.before();
  $.ajax({
    url: url,
    beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
    type: method,
    data: data,
    dataType: dataType,
    success: function(result){
      callbacks.after(result);
    }
  });
};

// args: formSelector(JS), callback (run if form is valid)}
Bpro.utils.formValidator = function(formSelector, valid) {
  if(formSelector.checkValidity()) {
    valid();
    return;
  }
  formSelector.reportValidity();
};

// args: element(Jquery), returns: Array of data-serializable elements
Bpro.utils.formSerializer = function(element) {
  let serializedArray = [];
  element.find('[data-serializable]').each(function() {
    serializedArray.push({name: $(this).data('serializable'), value: $(this).val()})
  });
  return serializedArray;
};

// args: element(Jquery)
Bpro.utils.formDeSerializer = function(element, serializedArray) {
  serializedArray.forEach((serialized) => {
    element.find(`[data-serializable='${serialized.name}']`).val(serialized.value);
  });
};

Bpro.utils.jsonDeserializer = function(string) {
  return JSON.parse(string);
};
Object.defineProperty(String.prototype, 'deserialize', {
  get: function() {
    return Bpro.utils.jsonDeserializer(this);
  }
});

// register callback without duplication
Bpro.events.onLoaded = function(callback) {
  Bpro.events.callbacks.onLoaded[Bpro.hashcode(callback.toString())] = callback;
};

Bpro.oneTimeKeystore = {
  map: {},
  write: function(key, value) {
    this.map[key] = value;
  },
  read: function(key) {
    let val = this.map[key];
    delete this.map[key];
    return val;
  },
  clear: function(){
    this.map = {};
  }
};

Bpro.hashcode = function(s){
  return s.split("").reduce(function(a,b){a=((a<<5)-a)+b.charCodeAt(0);return a&a},0);
};

Bpro.events.forceCallOnLoaded = function() {
  for(let callbackHashCode in Bpro.events.callbacks.onLoaded) {
    Bpro.events.callbacks.onLoaded[callbackHashCode]();
  }
};

$(document).on('turbolinks:load ajaxComplete ajax:complete', function() {
  Bpro.events.forceCallOnLoaded();
});
