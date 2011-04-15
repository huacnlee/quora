if (!this.Faye) Faye = {};

Faye.extend = function(dest, source, overwrite) {
  if (!source) return dest;
  for (var key in source) {
    if (!source.hasOwnProperty(key)) continue;
    if (dest.hasOwnProperty(key) && overwrite === false) continue;
    if (dest[key] !== source[key])
      dest[key] = source[key];
  }
  return dest;
};

Faye.extend(Faye, {
  VERSION:          '0.5.5',
  
  BAYEUX_VERSION:   '1.0',
  ID_LENGTH:        128,
  JSONP_CALLBACK:   'jsonpcallback',
  CONNECTION_TYPES: ['long-polling', 'callback-polling', 'websocket'],
  
  MANDATORY_CONNECTION_TYPES: ['long-polling', 'callback-polling', 'in-process'],
  
  ENV: (function() { return this })(),
  
  random: function(bitlength) {
    bitlength = bitlength || this.ID_LENGTH;
    if (bitlength > 32) {
      var parts  = Math.ceil(bitlength / 32),
          string = '';
      while (parts--) string += this.random(32);
      return string;
    }
    var field = Math.pow(2, bitlength);
    return Math.floor(Math.random() * field).toString(36);
  },
  
  commonElement: function(lista, listb) {
    for (var i = 0, n = lista.length; i < n; i++) {
      if (this.indexOf(listb, lista[i]) !== -1)
        return lista[i];
    }
    return null;
  },
  
  indexOf: function(list, needle) {
    for (var i = 0, n = list.length; i < n; i++) {
      if (list[i] === needle) return i;
    }
    return -1;
  },
  
  each: function(object, callback, scope) {
    if (object instanceof Array) {
      for (var i = 0, n = object.length; i < n; i++) {
        if (object[i] !== undefined)
          callback.call(scope || null, object[i], i);
      }
    } else {
      for (var key in object) {
        if (object.hasOwnProperty(key))
          callback.call(scope || null, key, object[key]);
      }
    }
  },
  
  map: function(object, callback, scope) {
    var result = [];
    this.each(object, function() {
      result.push(callback.apply(scope || null, arguments));
    });
    return result;
  },
  
  filter: function(array, callback, scope) {
    var result = [];
    this.each(array, function() {
      if (callback.apply(scope, arguments))
        result.push(arguments[0]);
    });
    return result;
  },
  
  size: function(object) {
    var size = 0;
    this.each(object, function() { size += 1 });
    return size;
  },
  
  enumEqual: function(actual, expected) {
    if (expected instanceof Array) {
      if (!(actual instanceof Array)) return false;
      var i = actual.length;
      if (i !== expected.length) return false;
      while (i--) {
        if (actual[i] !== expected[i]) return false;
      }
      return true;
    } else {
      if (!(actual instanceof Object)) return false;
      if (this.size(expected) !== this.size(actual)) return false;
      var result = true;
      this.each(actual, function(key, value) {
        result = result && (expected[key] === value);
      });
      return result;
    }
  },
  
  asyncEach: function(list, iterator) {
    var n       = list.length,
        i       = -1,
        calls   = 0,
        looping = false;

    var iterate = function() {
      calls -= 1;
      i += 1;
      if (i === n) return;
      iterator(list[i], resume);
    };

    var loop = function() {
      if (looping) return;
      looping = true;
      while (calls > 0) iterate();
      looping = false;
    };

    var resume = function() {
      calls += 1;
      loop();
    };
    resume();
  },
  
  // http://assanka.net/content/tech/2009/09/02/json2-js-vs-prototype/
  toJSON: function(object) {
    if (this.stringify)
      return this.stringify(object, function(key, value) {
        return (this[key] instanceof Array)
            ? this[key]
            : value;
      });
    
    return JSON.stringify(object);
  },
  
  timestamp: function() {
    var date   = new Date(),
        year   = date.getFullYear(),
        month  = date.getMonth() + 1,
        day    = date.getDate(),
        hour   = date.getHours(),
        minute = date.getMinutes(),
        second = date.getSeconds();
    
    var pad = function(n) {
      return n < 10 ? '0' + n : String(n);
    };
    
    return pad(year) + '-' + pad(month) + '-' + pad(day) + ' ' +
           pad(hour) + ':' + pad(minute) + ':' + pad(second);
  }
});


Faye.Class = function(parent, methods) {
  if (typeof parent !== 'function') {
    methods = parent;
    parent  = Object;
  }
  
  var klass = function() {
    if (!this.initialize) return this;
    return this.initialize.apply(this, arguments) || this;
  };
  
  var bridge = function() {};
  bridge.prototype = parent.prototype;
  
  klass.prototype = new bridge();
  Faye.extend(klass.prototype, methods);
  
  return klass;
};


Faye.Namespace = Faye.Class({
  initialize: function() {
    this._used = {};
  },
  
  generate: function() {
    var name = Faye.random();
    while (this._used.hasOwnProperty(name))
      name = Faye.random();
    return this._used[name] = name;
  }
});


Faye.Deferrable = {
  callback: function(callback, scope) {
    if (!callback) return;
    
    if (this._deferredStatus === 'succeeded')
      return callback.apply(scope, this._deferredArgs);
    
    this._callbacks = this._callbacks || [];
    this._callbacks.push([callback, scope]);
  },
  
  setDeferredStatus: function() {
    var args = Array.prototype.slice.call(arguments),
        status = args.shift();
    
    this._deferredStatus = status;
    this._deferredArgs = args;
    
    if (status !== 'succeeded') return;
    if (!this._callbacks) return;
    
    Faye.each(this._callbacks, function(callback) {
      callback[0].apply(callback[1], this._deferredArgs);
    }, this);
    
    this._callbacks = [];
  }
};


Faye.Publisher = {
  countSubscribers: function(eventType) {
    if (!this._subscribers || !this._subscribers[eventType]) return 0;
    return this._subscribers[eventType].length;
  },
  
  addSubscriber: function(eventType, listener, context) {
    this._subscribers = this._subscribers || {};
    var list = this._subscribers[eventType] = this._subscribers[eventType] || [];
    list.push([listener, context]);
  },
  
  removeSubscriber: function(eventType, listener, context) {
    if (!this._subscribers || !this._subscribers[eventType]) return;
    
    var list = this._subscribers[eventType],
        i    = list.length;
    
    while (i--) {
      if (listener && list[i][0] !== listener) continue;
      if (context && list[i][1] !== context) continue;
      list.splice(i,1);
    }
  },
  
  publishEvent: function() {
    var args = Array.prototype.slice.call(arguments),
        eventType = args.shift();
    
    if (!this._subscribers || !this._subscribers[eventType]) return;
    
    Faye.each(this._subscribers[eventType], function(listener) {
      listener[0].apply(listener[1], args);
    });
  }
};


Faye.Timeouts = {
  addTimeout: function(name, delay, callback, scope) {
    this._timeouts = this._timeouts || {};
    if (this._timeouts.hasOwnProperty(name)) return;
    var self = this;
    this._timeouts[name] = setTimeout(function() {
      delete self._timeouts[name];
      callback.call(scope);
    }, 1000 * delay);
  },
  
  removeTimeout: function(name) {
    this._timeouts = this._timeouts || {};
    var timeout = this._timeouts[name];
    if (!timeout) return;
    clearTimeout(timeout);
    delete this._timeouts[name];
  }
};


Faye.Logging = {
  LOG_LEVELS: {
    error:  3,
    warn:   2,
    info:   1,
    debug:  0
  },
  
  logLevel: 'error',
  
  log: function(messageArgs, level) {
    if (!Faye.logger) return;
    
    var levels = Faye.Logging.LOG_LEVELS;
    if (levels[Faye.Logging.logLevel] > levels[level]) return;
    
    var messageArgs = Array.prototype.slice.apply(messageArgs),
        banner = ' [' + level.toUpperCase() + '] [Faye',
        klass  = null,
        
        message = messageArgs.shift().replace(/\?/g, function() {
          try {
            return Faye.toJSON(messageArgs.shift());
          } catch (e) {
            return '[Object]';
          }
        });
    
    for (var key in Faye) {
      if (klass) continue;
      if (typeof Faye[key] !== 'function') continue;
      if (this instanceof Faye[key]) klass = key;
    }
    if (klass) banner += '.' + klass;
    banner += '] ';
    
    Faye.logger(Faye.timestamp() + banner + message);
  }
};

Faye.each(Faye.Logging.LOG_LEVELS, function(level, value) {
  Faye.Logging[level] = function() {
    this.log(arguments, level);
  };
});


Faye.Grammar = {

  LOWALPHA:     /^[a-z]$/,

  UPALPHA:     /^[A-Z]$/,

  ALPHA:     /^([a-z]|[A-Z])$/,

  DIGIT:     /^[0-9]$/,

  ALPHANUM:     /^(([a-z]|[A-Z])|[0-9])$/,

  MARK:     /^(\-|\_|\!|\~|\(|\)|\$|\@)$/,

  STRING:     /^(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)| |\/|\*|\.))*$/,

  TOKEN:     /^(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)))+$/,

  INTEGER:     /^([0-9])+$/,

  CHANNEL_SEGMENT:     /^(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)))+$/,

  CHANNEL_SEGMENTS:     /^(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)))+(\/(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)))+)*$/,

  CHANNEL_NAME:     /^\/(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)))+(\/(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)))+)*$/,

  WILD_CARD:     /^\*{1,2}$/,

  CHANNEL_PATTERN:     /^(\/(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)))+)*\/\*{1,2}$/,

  VERSION_ELEMENT:     /^(([a-z]|[A-Z])|[0-9])(((([a-z]|[A-Z])|[0-9])|\-|\_))*$/,

  VERSION:     /^([0-9])+(\.(([a-z]|[A-Z])|[0-9])(((([a-z]|[A-Z])|[0-9])|\-|\_))*)*$/,

  CLIENT_ID:     /^((([a-z]|[A-Z])|[0-9]))+$/,

  ID:     /^((([a-z]|[A-Z])|[0-9]))+$/,

  ERROR_MESSAGE:     /^(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)| |\/|\*|\.))*$/,

  ERROR_ARGS:     /^(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)| |\/|\*|\.))*(,(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)| |\/|\*|\.))*)*$/,

  ERROR_CODE:     /^[0-9][0-9][0-9]$/,

  ERROR:     /^([0-9][0-9][0-9]:(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)| |\/|\*|\.))*(,(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)| |\/|\*|\.))*)*:(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)| |\/|\*|\.))*|[0-9][0-9][0-9]::(((([a-z]|[A-Z])|[0-9])|(\-|\_|\!|\~|\(|\)|\$|\@)| |\/|\*|\.))*)$/

};


Faye.Extensible = {
  addExtension: function(extension) {
    this._extensions = this._extensions || [];
    this._extensions.push(extension);
    if (extension.added) extension.added();
  },
  
  removeExtension: function(extension) {
    if (!this._extensions) return;
    var i = this._extensions.length;
    while (i--) {
      if (this._extensions[i] !== extension) continue;
      this._extensions.splice(i,1);
      if (extension.removed) extension.removed();
    }
  },
  
  pipeThroughExtensions: function(stage, message, callback, scope) {
    if (!this._extensions) return callback.call(scope, message);
    var extensions = this._extensions.slice();
    
    var pipe = function(message) {
      if (!message) return callback.call(scope, message);
      
      var extension = extensions.shift();
      if (!extension) return callback.call(scope, message);
      
      if (extension[stage]) extension[stage](message, pipe);
      else pipe(message);
    };
    pipe(message);
  }
};


Faye.Channel = Faye.Class({
  initialize: function(name) {
    this.id = this.name = name;
  },
  
  push: function(message) {
    this.publishEvent('message', message);
  },
  
  isUnused: function() {
    return this.countSubscribers('message') === 0;
  }
});

Faye.extend(Faye.Channel.prototype, Faye.Publisher);

Faye.extend(Faye.Channel, {
  HANDSHAKE:    '/meta/handshake',
  CONNECT:      '/meta/connect',
  SUBSCRIBE:    '/meta/subscribe',
  UNSUBSCRIBE:  '/meta/unsubscribe',
  DISCONNECT:   '/meta/disconnect',
  
  META:         'meta',
  SERVICE:      'service',
  
  isValid: function(name) {
    return Faye.Grammar.CHANNEL_NAME.test(name) ||
           Faye.Grammar.CHANNEL_PATTERN.test(name);
  },
  
  parse: function(name) {
    if (!this.isValid(name)) return null;
    return name.split('/').slice(1);
  },
  
  isMeta: function(name) {
    var segments = this.parse(name);
    return segments ? (segments[0] === this.META) : null;
  },
  
  isService: function(name) {
    var segments = this.parse(name);
    return segments ? (segments[0] === this.SERVICE) : null;
  },
  
  isSubscribable: function(name) {
    if (!this.isValid(name)) return null;
    return !this.isMeta(name) && !this.isService(name);
  },
  
  Tree: Faye.Class({
    initialize: function(parent, value) {
      this._parent   = parent;
      this._value    = value;
      this._children = {};
    },
    
    eachChild: function(block, context) {
      Faye.each(this._children, function(key, subtree) {
        block.call(context, key, subtree);
      });
    },
    
    each: function(prefix, block, context) {
      this.eachChild(function(path, subtree) {
        path = prefix.concat(path);
        subtree.each(path, block, context);
      });
      if (this._value !== undefined) block.call(context, prefix, this._value);
    },
    
    getKeys: function() {
      return this.map(function(key, value) { return '/' + key.join('/') });
    },
    
    map: function(block, context) {
      var result = [];
      this.each([], function(path, value) {
        result.push(block.call(context, path, value));
      });
      return result;
    },
    
    get: function(name) {
      var tree = this.traverse(name);
      return tree ? tree._value : null;
    },
    
    set: function(name, value) {
      var subtree = this.traverse(name, true);
      if (subtree) subtree._value = value;
    },
    
    remove: function(name) {
      if (name) {
        var subtree = this.traverse(name);
        if (subtree) subtree.remove();
      } else {
        if (!this._parent) return;
        this._parent.removeChild(this);
        this._parent = this._value = undefined;
      }
    },
    
    removeChild: function(subtree) {
      this.eachChild(function(key, child) {
        if (child === subtree) delete this._children[key];
      }, this);
      if (Faye.size(this._children) === 0 && this._value === undefined)
        this.remove();
    },
    
    traverse: function(path, createIfAbsent) {
      if (typeof path === 'string') path = Faye.Channel.parse(path);
      
      if (path === null) return null;
      if (path.length === 0) return this;
      
      var subtree = this._children[path[0]];
      if (!subtree && !createIfAbsent) return null;
      if (!subtree) subtree = this._children[path[0]] = new Faye.Channel.Tree(this);
      
      return subtree.traverse(path.slice(1), createIfAbsent);
    },
    
    findOrCreate: function(channel) {
      var existing = this.get(channel);
      if (existing) return existing;
      existing = new Faye.Channel(channel);
      this.set(channel, existing);
      return existing;
    },
    
    glob: function(path) {
      if (typeof path === 'string') path = Faye.Channel.parse(path);
      
      if (path === null) return [];
      if (path.length === 0) return (this._value === undefined) ? [] : [this._value];
      
      var list = [];
      
      if (Faye.enumEqual(path, ['*'])) {
        Faye.each(this._children, function(key, subtree) {
          if (subtree._value !== undefined) list.push(subtree._value);
        });
        return list;
      }
      
      if (Faye.enumEqual(path, ['**'])) {
        list = this.map(function(key, value) { return value });
        if (this._value !== undefined) list.pop();
        return list;
      }
      
      Faye.each(this._children, function(key, subtree) {
        if (key !== path[0] && key !== '*') return;
        var sublist = subtree.glob(path.slice(1));
        Faye.each(sublist, function(channel) { list.push(channel) });
      });
      
      if (this._children['**']) list.push(this._children['**']._value);
      return list;
    },
    
    subscribe: function(names, callback, scope) {
      if (!callback) return;
      Faye.each(names, function(name) {
        var channel = this.findOrCreate(name);
        channel.addSubscriber('message', callback, scope);
      }, this);
    },
    
    unsubscribe: function(name, callback, scope) {
      var channel = this.get(name);
      if (!channel) return false;
      channel.removeSubscriber('message', callback, scope);
      
      if (channel.isUnused()) {
        this.remove(name);
        return true;
      } else {
        return false;
      }
    },
    
    distributeMessage: function(message) {
      var channels = this.glob(message.channel);
      Faye.each(channels, function(channel) {
        channel.publishEvent('message', message.data);
      });
    }
  })
});


Faye.Subscription = Faye.Class({
  initialize: function(client, channels, callback, scope) {
    this._client    = client;
    this._channels  = channels;
    this._callback  = callback;
    this._scope     = scope;
    this._cancelled = false;
  },
  
  cancel: function() {
    if (this._cancelled) return;
    this._client.unsubscribe(this._channels, this._callback, this._scope);
    this._cancelled = true;
  },
  
  unsubscribe: function() {
    this.cancel();
  }
});

Faye.extend(Faye.Subscription.prototype, Faye.Deferrable);


Faye.Client = Faye.Class({
  UNCONNECTED:          1,
  CONNECTING:           2,
  CONNECTED:            3,
  DISCONNECTED:         4,
  
  HANDSHAKE:            'handshake',
  RETRY:                'retry',
  NONE:                 'none',
  
  CONNECTION_TIMEOUT:   60.0,
  
  DEFAULT_ENDPOINT:     '/bayeux',
  MAX_DELAY:            0.001,
  INTERVAL:             0.0,
  
  initialize: function(endpoint, options) {
    this.info('New client created for ?', endpoint);
    
    this._endpoint  = endpoint || this.DEFAULT_ENDPOINT;
    this._options   = options || {};
    
    Faye.Transport.get(this, Faye.MANDATORY_CONNECTION_TYPES, function(transport) {
      this._transport = transport;
    }, this);
    
    this._state     = this.UNCONNECTED;
    this._outbox    = [];
    this._channels  = new Faye.Channel.Tree();
    
    this._namespace = new Faye.Namespace();
    this._responseCallbacks = {};
    
    this._advice = {
      reconnect: this.RETRY,
      interval:  1000 * (this._options.interval || this.INTERVAL),
      timeout:   1000 * (this._options.timeout  || this.CONNECTION_TIMEOUT)
    };
    
    if (Faye.Event) Faye.Event.on(Faye.ENV, 'beforeunload',
                                  this.disconnect, this);
  },
  
  // Request
  // MUST include:  * channel
  //                * version
  //                * supportedConnectionTypes
  // MAY include:   * minimumVersion
  //                * ext
  //                * id
  // 
  // Success Response                             Failed Response
  // MUST include:  * channel                     MUST include:  * channel
  //                * version                                    * successful
  //                * supportedConnectionTypes                   * error
  //                * clientId                    MAY include:   * supportedConnectionTypes
  //                * successful                                 * advice
  // MAY include:   * minimumVersion                             * version
  //                * advice                                     * minimumVersion
  //                * ext                                        * ext
  //                * id                                         * id
  //                * authSuccessful
  handshake: function(callback, scope) {
    if (this._advice.reconnect === this.NONE) return;
    if (this._state !== this.UNCONNECTED) return;
    
    this._state = this.CONNECTING;
    var self = this;
    
    this.info('Initiating handshake with ?', this._endpoint);
    
    this._send({
      channel:      Faye.Channel.HANDSHAKE,
      version:      Faye.BAYEUX_VERSION,
      supportedConnectionTypes: [this._transport.connectionType]
      
    }, function(response) {
      
      if (response.successful) {
        this._state     = this.CONNECTED;
        this._clientId  = response.clientId;
        
        Faye.Transport.get(this, response.supportedConnectionTypes, function(transport) {
          this._transport = transport;
        }, this);
        
        this.info('Handshake successful: ?', this._clientId);
        
        this.subscribe(this._channels.getKeys());
        if (callback) callback.call(scope);
        
      } else {
        this.info('Handshake unsuccessful');
        setTimeout(function() { self.handshake(callback, scope) }, this._advice.interval);
        this._state = this.UNCONNECTED;
      }
    }, this);
  },
  
  // Request                              Response
  // MUST include:  * channel             MUST include:  * channel
  //                * clientId                           * successful
  //                * connectionType                     * clientId
  // MAY include:   * ext                 MAY include:   * error
  //                * id                                 * advice
  //                                                     * ext
  //                                                     * id
  //                                                     * timestamp
  connect: function(callback, scope) {
    if (this._advice.reconnect === this.NONE) return;
    if (this._state === this.DISCONNECTED) return;
    
    if (this._state === this.UNCONNECTED)
      return this.handshake(function() { this.connect(callback, scope) }, this);
    
    this.callback(callback, scope);
    if (this._state !== this.CONNECTED) return;
    
    this.info('Calling deferred actions for ?', this._clientId);
    this.setDeferredStatus('succeeded');
    this.setDeferredStatus('deferred');
    
    if (this._connectRequest) return;
    this._connectRequest = true;
    
    this.info('Initiating connection for ?', this._clientId);
    
    this._send({
      channel:        Faye.Channel.CONNECT,
      clientId:       this._clientId,
      connectionType: this._transport.connectionType
      
    }, this._cycleConnection, this);
  },
  
  // Request                              Response
  // MUST include:  * channel             MUST include:  * channel
  //                * clientId                           * successful
  // MAY include:   * ext                                * clientId
  //                * id                  MAY include:   * error
  //                                                     * ext
  //                                                     * id
  disconnect: function() {
    if (this._state !== this.CONNECTED) return;
    this._state = this.DISCONNECTED;
    
    this.info('Disconnecting ?', this._clientId);
    
    this._send({
      channel:    Faye.Channel.DISCONNECT,
      clientId:   this._clientId
    });
    
    this.info('Clearing channel listeners for ?', this._clientId);
    this._channels = new Faye.Channel.Tree();
  },
  
  // Request                              Response
  // MUST include:  * channel             MUST include:  * channel
  //                * clientId                           * successful
  //                * subscription                       * clientId
  // MAY include:   * ext                                * subscription
  //                * id                  MAY include:   * error
  //                                                     * advice
  //                                                     * ext
  //                                                     * id
  //                                                     * timestamp
  subscribe: function(channels, callback, scope) {
    if (channels instanceof Array)
      return  Faye.each(channels, function(channel) {
                this.subscribe(channel, callback, scope);
              }, this);
    
    this._validateChannel(channels);
    var subscription = new Faye.Subscription(this, channels, callback, scope);
    
    this.connect(function() {
      this.info('Client ? attempting to subscribe to ?', this._clientId, channels);
      
      this._send({
        channel:      Faye.Channel.SUBSCRIBE,
        clientId:     this._clientId,
        subscription: channels
        
      }, function(response) {
        if (!response.successful) return;
        
        var channels = [].concat(response.subscription);
        this.info('Subscription acknowledged for ? to ?', this._clientId, channels);
        this._channels.subscribe(channels, callback, scope);
        
        subscription.setDeferredStatus('succeeded');
      }, this);
      
    }, this);
    
    return subscription;
  },
  
  // Request                              Response
  // MUST include:  * channel             MUST include:  * channel
  //                * clientId                           * successful
  //                * subscription                       * clientId
  // MAY include:   * ext                                * subscription
  //                * id                  MAY include:   * error
  //                                                     * advice
  //                                                     * ext
  //                                                     * id
  //                                                     * timestamp
  unsubscribe: function(channels, callback, scope) {
    if (channels instanceof Array)
      return  Faye.each(channels, function(channel) {
                this.unsubscribe(channel, callback, scope);
              }, this);
    
    this._validateChannel(channels);
    
    var dead = this._channels.unsubscribe(channels, callback, scope);
    if (!dead) return;
    
    this.connect(function() {
      this.info('Client ? attempting to unsubscribe from ?', this._clientId, channels);
      
      this._send({
        channel:      Faye.Channel.UNSUBSCRIBE,
        clientId:     this._clientId,
        subscription: channels
        
      }, function(response) {
        if (!response.successful) return;
        
        var channels = [].concat(response.subscription);
        this.info('Unsubscription acknowledged for ? from ?', this._clientId, channels);
      }, this);
      
    }, this);
  },
  
  // Request                              Response
  // MUST include:  * channel             MUST include:  * channel
  //                * data                               * successful
  // MAY include:   * clientId            MAY include:   * id
  //                * id                                 * error
  //                * ext                                * ext
  publish: function(channel, data) {
    this._validateChannel(channel);
    
    this.connect(function() {
      this.info('Client ? queueing published message to ?: ?', this._clientId, channel, data);
      
      this._send({
        channel:      channel,
        data:         data,
        clientId:     this._clientId
      });
    }, this);
  },
  
  receiveMessage: function(message) {
    this.pipeThroughExtensions('incoming', message, function(message) {
      if (!message) return;
      
      if (message.advice) this._handleAdvice(message.advice);
      
      var callback = this._responseCallbacks[message.id];
      if (callback) {
        delete this._responseCallbacks[message.id];
        callback[0].call(callback[1], message);
      }
      
      this._deliverMessage(message);
    }, this);
  },
  
  _handleAdvice: function(advice) {
    Faye.extend(this._advice, advice);
    
    if (this._advice.reconnect === this.HANDSHAKE && this._state !== this.DISCONNECTED) {
      this._state    = this.UNCONNECTED;
      this._clientId = null;
      this._cycleConnection();
    }
  },
  
  _deliverMessage: function(message) {
    if (!message.channel || !message.data) return;
    this.info('Client ? calling listeners for ? with ?', this._clientId, message.channel, message.data);
    this._channels.distributeMessage(message);
  },
  
  _teardownConnection: function() {
    if (!this._connectRequest) return;
    this._connectRequest = null;
    this.info('Closed connection for ?', this._clientId);
  },
  
  _cycleConnection: function() {
    this._teardownConnection();
    var self = this;
    setTimeout(function() { self.connect() }, this._advice.interval);
  },
  
  _send: function(message, callback, scope) {
    message.id = this._namespace.generate();
    if (callback) this._responseCallbacks[message.id] = [callback, scope];
    
    this.pipeThroughExtensions('outgoing', message, function(message) {
      if (!message) return;
      
      if (message.channel === Faye.Channel.HANDSHAKE)
        return this._transport.send(message, this._advice.timeout / 1000);
      
      this._outbox.push(message);
      
      if (message.channel === Faye.Channel.CONNECT)
        this._connectMessage = message;
      
      this.addTimeout('publish', this.MAX_DELAY, this._flush, this);
    }, this);
  },
  
  _flush: function() {
    this.removeTimeout('publish');
    
    if (this._outbox.length > 1 && this._connectMessage)
      this._connectMessage.advice = {timeout: 0};
    
    this._connectMessage = null;
    
    this._transport.send(this._outbox, this._advice.timeout / 1000);
    this._outbox = [];
  },
  
  _validateChannel: function(channel) {
    if (!Faye.Channel.isValid(channel))
      throw '"' + channel + '" is not a valid channel name';
    if (!Faye.Channel.isSubscribable(channel))
      throw 'Clients may not subscribe to channel "' + channel + '"';
  }
});

Faye.extend(Faye.Client.prototype, Faye.Deferrable);
Faye.extend(Faye.Client.prototype, Faye.Timeouts);
Faye.extend(Faye.Client.prototype, Faye.Logging);
Faye.extend(Faye.Client.prototype, Faye.Extensible);


Faye.Transport = Faye.extend(Faye.Class({
  initialize: function(client, endpoint) {
    this.debug('Created new ? transport for ?', this.connectionType, endpoint);
    this._client    = client;
    this._endpoint  = endpoint;
  },
  
  send: function(messages, timeout) {
    messages = [].concat(messages);
    
    this.debug('Client ? sending message to ?: ?',
               this._client._clientId, this._endpoint, messages);
    
    return this.request(messages, timeout);
  },
  
  receive: function(responses) {
    this.debug('Client ? received from ?: ?',
               this._client._clientId, this._endpoint, responses);
    
    Faye.each(responses, this._client.receiveMessage, this._client);
  },
  
  retry: function(message, timeout) {
    var self = this;
    return function() {
      setTimeout(function() { self.request(message, 2 * timeout) }, 1000 * timeout);
    };
  }
  
}), {
  get: function(client, connectionTypes, callback, scope) {
    var endpoint = client._endpoint;
    if (connectionTypes === undefined) connectionTypes = this.supportedConnectionTypes();
    
    Faye.asyncEach(this._transports, function(pair, resume) {
      var connType = pair[0], klass = pair[1];
      if (Faye.indexOf(connectionTypes, connType) < 0) return resume();
      
      klass.isUsable(endpoint, function(isUsable) {
        if (isUsable) callback.call(scope, new klass(client, endpoint));
        else resume();
      });
    }, function() {
      throw 'Could not find a usable connection type for ' + endpoint;
    });
  },
  
  register: function(type, klass) {
    this._transports.push([type, klass]);
    klass.prototype.connectionType = type;
  },
  
  _transports: [],
  
  supportedConnectionTypes: function() {
    return Faye.map(this._transports, function(pair) { return pair[0] });
  }
});

Faye.extend(Faye.Transport.prototype, Faye.Logging);


Faye.Set = Faye.Class({
  initialize: function() {
    this._index = {};
  },
  
  add: function(item) {
    var key = (item.id !== undefined) ? item.id : item;
    if (this._index.hasOwnProperty(key)) return false;
    this._index[key] = item;
    return true;
  },
  
  forEach: function(block, scope) {
    for (var key in this._index) {
      if (this._index.hasOwnProperty(key))
        block.call(scope, this._index[key]);
    }
  },
  
  isEmpty: function() {
    for (var key in this._index) {
      if (this._index.hasOwnProperty(key)) return false;
    }
    return true;
  },
  
  member: function(item) {
    for (var key in this._index) {
      if (this._index[key] === item) return true;
    }
    return false;
  },
  
  remove: function(item) {
    var key = (item.id !== undefined) ? item.id : item;
    delete this._index[key];
  },
  
  toArray: function() {
    var array = [];
    this.forEach(function(item) { array.push(item) });
    return array;
  }
});


/**
 * Generic WebSocket implementation for Node
 * -----------------------------------------
 * 
 * Though primarily here to support WebSockets as a network
 * transport in Faye, it would be nice for this class to
 * implement the same interface as the client-side WebSocket
 * for ease of use.
 * 
 * For implementation reference:
 * http://dev.w3.org/html5/websockets/
 * http://tools.ietf.org/html/draft-hixie-thewebsocketprotocol-75
 * http://tools.ietf.org/html/draft-hixie-thewebsocketprotocol-76
 * http://www.w3.org/TR/DOM-Level-2-Events/events.html
 **/

var Buffer = require('buffer').Buffer,
    crypto = require('crypto');

Faye.WebSocket = Faye.Class({
  onopen:     null,
  onmessage:  null,
  onerror:    null,
  onclose:    null,
  
  initialize: function(request, head) {
    this._request = request;
    this._head    = head;
    this._stream  = request.socket;
    
    var scheme = Faye.WebSocket.isSecureConnection(request) ? 'wss:' : 'ws:';
    this.url = scheme + '//' + request.headers.host + request.url;    
    this.readyState = Faye.WebSocket.CONNECTING;
    this.bufferedAmount = 0;
    
    this._handler = Faye.WebSocket.getHandler(request);
    this._handler.handshake(this.url, this._request, this._head, this._stream);
    this.readyState = Faye.WebSocket.OPEN;
    
    var event = new Faye.WebSocket.Event();
    event.initEvent('open', false, false);
    this.dispatchEvent(event);
    
    this._buffer = [];
    this._buffering = false;
    
    var self = this;
    
    this._stream.addListener('data', function(data) {
      for (var i = 0, n = data.length; i < n; i++)
        self._handleChar(data[i]);
    });
  },
  
  send: function(data) {
    this._handler.send(this._stream, data);
    return true;
  },
  
  close: function() {},
  
  addEventListener: function(type, listener, useCapture) {
    this.addSubscriber(type, listener);
  },
  
  removeEventListener: function(type, listener, useCapture) {
    this.removeSubscriber(type, listener);
  },
  
  dispatchEvent: function(event) {
    event.target = event.currentTarget = this;
    event.eventPhase = Faye.WebSocket.Event.AT_TARGET;
    
    this.publishEvent(event.type, event);
    if (this['on' + event.type])
      this['on' + event.type](event);
  },
  
  _handleChar: function(data) {
    switch (data) {
      case 0x00:
        this._buffering = true;
        break;
      
      case 0xFF:
        this._buffer = new Buffer(this._buffer);
        
        var event = new Faye.WebSocket.Event();
        event.initEvent('message', false, false);
        event.data = this._buffer.toString('utf8', 0, this._buffer.length);
        
        this.dispatchEvent(event);
        
        this._buffer = [];
        this._buffering = false;
        break;
      
      default:
        if (this._buffering) this._buffer.push(data);
    }
  }
});

Faye.extend(Faye.WebSocket.prototype, Faye.Publisher);

Faye.extend(Faye.WebSocket, {
  CONNECTING:   0,
  OPEN:         1,
  CLOSING:      2,
  CLOSED:       3,
  
  Event: Faye.extend(Faye.Class({
    initEvent: function(eventType, canBubble, cancelable) {
      this.type       = eventType;
      this.bubbles    = canBubble;
      this.cancelable = cancelable;
    },
    
    stopPropagation: function() {},
    preventDefault: function() {}
    
  }), {
    CAPTURING_PHASE:  1,
    AT_TARGET:        2,
    BUBBLING_PHASE:   3
  }),
  
  getHandler: function(request) {
    var headers = request.headers;
    return (headers['sec-websocket-key1'] && headers['sec-websocket-key2'])
         ? this.Protocol76
         : this.Protocol75;
  },
  
  isSecureConnection: function(request) {
    if (request.headers['x-forwarded-proto']) {
      return request.headers['x-forwarded-proto'] == 'https';
    } else {
      return request.socket.secure;
    }
  }
});

(function() {
  var byteToChar = function(value) {
    if (typeof value === 'string') value = parseInt(value, 16);
    return String.fromCharCode(value);
  };
  
  var numberFromKey = function(key) {
    return parseInt(key.match(/[0-9]/g).join(''), 10);
  };
  
  var spacesInKey = function(key) {
    return key.match(/ /g).length;
  };
  
  var bigEndian = function(number) {
    var string = '';
    Faye.each([24,16,8,0], function(offset) {
      string += String.fromCharCode(number >> offset & 0xFF);
    });
    return string;
  };
  
  var writeToSocket = function(socket, message) {
    socket.write(FRAME_START, 'binary');
    socket.write(message, 'utf8');
    socket.write(FRAME_END, 'binary');
  };
  
  var FRAME_START = byteToChar('00'),
      FRAME_END   = byteToChar('FF');
  
  Faye.WebSocket.Protocol75 = {
    handshake: function(url, request, head, socket) {
      try {
        socket.write('HTTP/1.1 101 Web Socket Protocol Handshake\r\n');
        socket.write('Upgrade: WebSocket\r\n');
        socket.write('Connection: Upgrade\r\n');
        socket.write('WebSocket-Origin: ' + request.headers.origin + '\r\n');
        socket.write('WebSocket-Location: ' + url + '\r\n');
        socket.write('\r\n');
      } catch (e) {
        // socket closed while writing
        // no handshake sent; client will stop using WebSocket
      }
    },
    
    send: function(socket, message) {
      writeToSocket(socket, message);
    }
  };
  
  Faye.WebSocket.Protocol76 = {
    handshake: function(url, request, head, socket) {
      var key1   = request.headers['sec-websocket-key1'],
          value1 = numberFromKey(key1) / spacesInKey(key1),
          
          key2   = request.headers['sec-websocket-key2'],
          value2 = numberFromKey(key2) / spacesInKey(key2),
          
          MD5    = crypto.createHash('md5');
      
      MD5.update(bigEndian(value1));
      MD5.update(bigEndian(value2));
      MD5.update(head.toString('binary'));
      
      try {
        socket.write('HTTP/1.1 101 Web Socket Protocol Handshake\r\n', 'binary');
        socket.write('Upgrade: WebSocket\r\n', 'binary');
        socket.write('Connection: Upgrade\r\n', 'binary');
        socket.write('Sec-WebSocket-Origin: ' + request.headers.origin + '\r\n', 'binary');
        socket.write('Sec-WebSocket-Location: ' + url + '\r\n', 'binary');
        socket.write('\r\n', 'binary');
        socket.write(MD5.digest('binary'), 'binary');
      } catch (e) {
        // socket closed while writing
        // no handshake sent; client will stop using WebSocket
      }
    },
    
    send: function(socket, message) {
      writeToSocket(socket, message);
    }
  }
})();


Faye.Error = Faye.Class({
  initialize: function(code, args, message) {
    this.code    = code;
    this.args    = Array.prototype.slice.call(args);
    this.message = message;
  },
  
  toString: function() {
    return this.code + ':' +
           this.args.join(',') + ':' +
           this.message;
  }
});


Faye.Error.versionMismatch = function() {
  return new this(300, arguments, "Version mismatch").toString();
};

Faye.Error.conntypeMismatch = function() {
  return new this(301, arguments, "Connection types not supported").toString();
};

Faye.Error.extMismatch = function() {
  return new this(302, arguments, "Extension mismatch").toString();
};

Faye.Error.badRequest = function() {
  return new this(400, arguments, "Bad request").toString();
};

Faye.Error.clientUnknown = function() {
  return new this(401, arguments, "Unknown client").toString();
};

Faye.Error.parameterMissing = function() {
  return new this(402, arguments, "Missing required parameter").toString();
};

Faye.Error.channelForbidden = function() {
  return new this(403, arguments, "Forbidden channel").toString();
};

Faye.Error.channelUnknown = function() {
  return new this(404, arguments, "Unknown channel").toString();
};

Faye.Error.channelInvalid = function() {
  return new this(405, arguments, "Invalid channel").toString();
};

Faye.Error.extUnknown = function() {
  return new this(406, arguments, "Unknown extension").toString();
};

Faye.Error.publishFailed = function() {
  return new this(407, arguments, "Failed to publish").toString();
};

Faye.Error.serverError = function() {
  return new this(500, arguments, "Internal server error").toString();
};



Faye.Server = Faye.Class({
  initialize: function(options) {
    this.info('New server created');
    this._options     = options || {};
    this._channels    = new Faye.Channel.Tree();
    this._connections = {};
    this._namespace   = new Faye.Namespace();
  },
  
  clientIds: function() {
    return Faye.map(this._connections, function(key, value) { return key });
  },
  
  determineClient: function(messages) {
    messages = [].concat(messages);
    var i = messages.length, message;
    while (i--) {
      message = messages[i];
      if (message.channel === Faye.Channel.CONNECT)
        return message.clientId;
    }
    return null;
  },
  
  process: function(messages, localOrRemote, callback, scope) {
    var socket = (localOrRemote instanceof Faye.WebSocket) ? localOrRemote : null,
        local  = (localOrRemote === true);
    
    this.debug('Processing messages from ? client', local ? 'LOCAL' : 'REMOTE');
    
    messages = [].concat(messages);
    var processed = 0, responses = [];
    
    var gatherReplies = function(replies) {
      responses = responses.concat(replies);
      processed += 1;
      if (processed < messages.length) return;
      
      var n = responses.length;
      while (n--) {
        if (!responses[n]) responses.splice(n,1);
      }
      callback.call(scope, responses);
    };
    
    var handleReply = function(replies) {
      var extended = 0, expected = replies.length;
      if (expected === 0) gatherReplies(replies);
      
      Faye.each(replies, function(reply, i) {
        this.pipeThroughExtensions('outgoing', reply, function(message) {
          replies[i] = message;
          extended  += 1;
          if (extended === expected) gatherReplies(replies);
        });
      }, this);
    };
    
    Faye.each(messages, function(message) {
      this.pipeThroughExtensions('incoming', message, function(pipedMessage) {
        this._handle(pipedMessage, socket, local, handleReply, this);
      }, this);
    }, this);
  },
  
  flushConnection: function(messages) {
    messages = [].concat(messages);
    Faye.each(messages, function(message) {
      var connection = this._connections[message.clientId];
      if (connection) connection.flush();
    }, this);
  },
  
  _connection: function(id) {
    if (this._connections.hasOwnProperty(id)) return this._connections[id];
    var connection = new Faye.Connection(id, this._options);
    connection.addSubscriber('staleConnection', this._destroyConnection, this);
    return this._connections[id] = connection;
  },
  
  _destroyConnection: function(connection) {
    connection.disconnect();
    connection.removeSubscriber('staleConnection', this._destroyConnection, this);
    delete this._connections[connection.id];
  },
  
  _makeResponse: function(message) {
    var response = {};
    Faye.each(['id', 'clientId', 'channel', 'error'], function(field) {
      if (message[field]) response[field] = message[field];
    });
    response.successful = !response.error;
    return response;
  },
  
  _distributeMessage: function(message) {
    if (message.error) return;
    Faye.each(this._channels.glob(message.channel), function(channel) {
      channel.push(message);
      this.info('Publishing message ? from client ? to ?', message.data, message.clientId, channel.name);
    }, this);
  },
  
  _handle: function(message, socket, local, callback, scope) {
    if (!message) return callback.call(scope, []);
    
    this._distributeMessage(message);
    var channelName = message.channel, response;
    
    if (Faye.Channel.isMeta(channelName)) {
      this._handleMeta(message, socket, local, callback, scope);
    } else if (!message.clientId) {
      callback.call(scope, []);
    } else {
      response = this._makeResponse(message);
      response.successful = !response.error;
      callback.call(scope, [response]);
    }
  },
  
  _handleMeta: function(message, socket, local, callback, scope) {
    var response = this[Faye.Channel.parse(message.channel)[1]](message, local);
    
    this._advize(response);
    
    if (response.channel === Faye.Channel.CONNECT && response.successful === true)
      return this._acceptConnection(message.advice, response, socket, callback, scope);
    
    callback.call(scope, [response]);
  },
  
  _acceptConnection: function(options, response, socket, callback, scope) {
    this.info('Accepting connection from ?', response.clientId);
    
    var connection = this._connection(response.clientId);
    
    // Disabled because CometD doesn't like messages not being
    // delivered as part of a /meta/* response
    // if (socket) return connection.setSocket(socket);
    
    connection.connect(options, function(events) {
      this.info('Sending event messages to ?', response.clientId);
      this.debug('Events for ?: ?', response.clientId, events);
      callback.call(scope, [response].concat(events));
    }, this);
  },
  
  _advize: function(response) {
    var connection = this._connections[response.clientId];
    
    response.advice = response.advice || {};
    if (connection) {
      Faye.extend(response.advice, {
        reconnect:  'retry',
        interval:   Math.floor(connection.interval * 1000),
        timeout:    Math.floor(connection.timeout * 1000)
      }, false);
    } else {
      Faye.extend(response.advice, {
        reconnect:  'handshake'
      }, false);
    }
  },
  
  // MUST contain  * version
  //               * supportedConnectionTypes
  // MAY contain   * minimumVersion
  //               * ext
  //               * id
  handshake: function(message, local) {
    var response = this._makeResponse(message);
    response.version = Faye.BAYEUX_VERSION;
    
    if (!message.version)
      response.error = Faye.Error.parameterMissing('version');
    
    var clientConns = message.supportedConnectionTypes,
        commonConns;
    
    if (!local) {
      response.supportedConnectionTypes = Faye.CONNECTION_TYPES;
      
      if (clientConns) {
        commonConns = Faye.filter(clientConns, function(conn) {
          return Faye.indexOf(Faye.CONNECTION_TYPES, conn) !== -1;
        });
        if (commonConns.length === 0)
          response.error = Faye.Error.conntypeMismatch(clientConns);
      } else {
        response.error = Faye.Error.parameterMissing('supportedConnectionTypes');
      }
    }
    
    response.successful = !response.error;
    if (!response.successful) return response;
    
    var clientId = this._namespace.generate();
    response.clientId = this._connection(clientId).id;
    this.info('Accepting handshake from client ?', response.clientId);
    return response;
  },
  
  // MUST contain  * clientId
  //               * connectionType
  // MAY contain   * ext
  //               * id
  connect: function(message, local) {
    var response   = this._makeResponse(message);
    
    var clientId   = message.clientId,
        connection = clientId ? this._connections[clientId] : null,
        connectionType = message.connectionType;
    
    if (!connection)     response.error = Faye.Error.clientUnknown(clientId);
    if (!clientId)       response.error = Faye.Error.parameterMissing('clientId');
    if (!connectionType) response.error = Faye.Error.parameterMissing('connectionType');
    
    response.successful = !response.error;
    if (!response.successful) delete response.clientId;
    if (!response.successful) return response;
    
    response.clientId = connection.id;
    return response;
  },
  
  // MUST contain  * clientId
  // MAY contain   * ext
  //               * id
  disconnect: function(message, local) {
    var response   = this._makeResponse(message);
    
    var clientId   = message.clientId,
        connection = clientId ? this._connections[clientId] : null;
    
    if (!connection) response.error = Faye.Error.clientUnknown(clientId);
    if (!clientId)   response.error = Faye.Error.parameterMissing('clientId');
    
    response.successful = !response.error;
    if (!response.successful) delete response.clientId;
    if (!response.successful) return response;
    
    this._destroyConnection(connection);
    
    this.info('Disconnected client: ?', clientId);
    response.clientId = clientId;
    return response;
  },
  
  // MUST contain  * clientId
  //               * subscription
  // MAY contain   * ext
  //               * id
  subscribe: function(message, local) {
    var response     = this._makeResponse(message);
    
    var clientId     = message.clientId,
        connection   = clientId ? this._connections[clientId] : null,
        subscription = message.subscription;
    
    subscription = [].concat(subscription);
    
    if (!connection)           response.error = Faye.Error.clientUnknown(clientId);
    if (!clientId)             response.error = Faye.Error.parameterMissing('clientId');
    if (!message.subscription) response.error = Faye.Error.parameterMissing('subscription');
    
    response.subscription = subscription;
    
    Faye.each(subscription, function(channelName) {
      if (response.error) return;
      if (!local && !Faye.Channel.isSubscribable(channelName)) response.error = Faye.Error.channelForbidden(channelName);
      if (!Faye.Channel.isValid(channelName))                  response.error = Faye.Error.channelInvalid(channelName);
      
      if (response.error) return;
      var channel = this._channels.findOrCreate(channelName);
      
      this.info('Subscribing client ? to ?', clientId, channel.name);
      connection.subscribe(channel);
    }, this);
    
    response.successful = !response.error;
    return response;
  },
  
  // MUST contain  * clientId
  //               * subscription
  // MAY contain   * ext
  //               * id
  unsubscribe: function(message, local) {
    var response     = this._makeResponse(message);
    
    var clientId     = message.clientId,
        connection   = clientId ? this._connections[clientId] : null,
        subscription = message.subscription;
    
    subscription = [].concat(subscription);
    
    if (!connection)           response.error = Faye.Error.clientUnknown(clientId);
    if (!clientId)             response.error = Faye.Error.parameterMissing('clientId');
    if (!message.subscription) response.error = Faye.Error.parameterMissing('subscription');
    
    response.subscription = subscription;
    
    Faye.each(subscription, function(channelName) {
      if (response.error) return;
      
      if (!Faye.Channel.isValid(channelName))
        return response.error = Faye.Error.channelInvalid(channelName);
      
      var channel = this._channels.get(channelName);
      if (!channel) return;
      
      this.info('Unsubscribing client ? from ?', clientId, channel.name);
      connection.unsubscribe(channel);
      if (channel.isUnused()) this._channels.remove(channelName);
    }, this);
    
    response.successful = !response.error;
    return response;
  }
});

Faye.extend(Faye.Server.prototype, Faye.Logging);
Faye.extend(Faye.Server.prototype, Faye.Extensible);


Faye.Connection = Faye.Class({
  MAX_DELAY:  0.001,
  INTERVAL:   0.0,
  TIMEOUT:    60.0,
  
  initialize: function(id, options) {
    this.id         = id;
    this._options   = options;
    this.interval   = this._options.interval || this.INTERVAL;
    this.timeout    = this._options.timeout || this.TIMEOUT;
    this._channels  = new Faye.Set();
    this._inbox     = new Faye.Set();
    this._connected = false;
    
    this._beginDeletionTimeout();
  },
  
  setSocket: function(socket) {
    this._connected = true;
    this._socket    = socket;
  },
  
  _onMessage: function(event) {
    if (!this._inbox.add(event)) return;
    if (this._socket) this._socket.send(Faye.toJSON(event));
    this._beginDeliveryTimeout();
  },
  
  subscribe: function(channel) {
    if (!this._channels.add(channel)) return;
    channel.addSubscriber('message', this._onMessage, this);
  },
  
  unsubscribe: function(channel) {
    if (channel === 'all') return this._channels.forEach(this.unsubscribe, this);
    if (!this._channels.member(channel)) return;
    this._channels.remove(channel);
    channel.removeSubscriber('message', this._onMessage, this);
  },
  
  connect: function(options, callback, scope) {
    options = options || {};
    var timeout = (options.timeout !== undefined) ? options.timeout / 1000 : this.timeout;
    
    this.setDeferredStatus('deferred');
    
    this.callback(callback, scope);
    if (this._connected) return;
    
    this._connected = true;
    this.removeTimeout('deletion');
    
    this._beginDeliveryTimeout();
    this._beginConnectionTimeout(timeout);
  },
  
  flush: function() {
    if (!this._connected) return;
    this._releaseConnection();
    
    var events = this._inbox.toArray();
    this._inbox = new Faye.Set();
    
    this.setDeferredStatus('succeeded', events);
    this.setDeferredStatus('deferred');
  },
  
  disconnect: function() {
    this.unsubscribe('all');
    this.flush();
  },
  
  _releaseConnection: function() {
    if (this._socket) return;
    
    this.removeTimeout('connection');
    this.removeTimeout('delivery');
    this._connected = false;
    
    this._beginDeletionTimeout();
  },
  
  _beginDeliveryTimeout: function() {
    if (!this._connected || this._inbox.isEmpty()) return;
    this.addTimeout('delivery', this.MAX_DELAY, this.flush, this);
  },
  
  _beginConnectionTimeout: function(timeout) {
    if (!this._connected) return;
    this.addTimeout('connection', timeout, this.flush, this);
  },
  
  _beginDeletionTimeout: function() {
    if (this._connected) return;
    this.addTimeout('deletion', this.TIMEOUT + 10 * this.timeout, function() {
      this.publishEvent('staleConnection', this);
    }, this);
  }
});

Faye.extend(Faye.Connection.prototype, Faye.Deferrable);
Faye.extend(Faye.Connection.prototype, Faye.Publisher);
Faye.extend(Faye.Connection.prototype, Faye.Timeouts);


Faye.NodeHttpTransport = Faye.Class(Faye.Transport, {
  request: function(message, timeout) {
    var uri      = url.parse(this._endpoint),
        secure   = (uri.protocol === 'https:'),
        port     = (secure ? 443 : 80),
        client   = http.createClient(uri.port || port, uri.hostname, secure),
        content  = JSON.stringify(message),
        response = null,
        retry    = this.retry(message, timeout),
        self     = this;
    
    client.addListener('error', retry);
    
    client.addListener('end', function() {
      if (!response) retry();
    });
    
    var request = client.request('POST', uri.pathname, {
      'Content-Type':   'application/json',
      'Host':           uri.hostname,
      'Content-Length': content.length
    });
    
    request.addListener('response', function(stream) {
      response = stream;
      Faye.withDataFor(response, function(data) {
        try {
          self.receive(JSON.parse(data));
        } catch (e) {
          retry();
        }
      });
    });
    
    request.write(content);
    request.end();
  }
});

Faye.NodeHttpTransport.isUsable = function(endpoint, callback, scope) {
  callback.call(scope, typeof endpoint === 'string');
};

Faye.Transport.register('long-polling', Faye.NodeHttpTransport);

Faye.NodeLocalTransport = Faye.Class(Faye.Transport, {
  request: function(message, timeout) {
    this._endpoint.process(message, true, this.receive, this);
  }
});

Faye.NodeLocalTransport.isUsable = function(endpoint, callback, scope) {
  callback.call(scope, endpoint instanceof Faye.Server);
};

Faye.Transport.register('in-process', Faye.NodeLocalTransport);


var path  = require('path'),
    fs    = require('fs'),
    sys   = require('sys'),
    url   = require('url'),
    http  = require('http'),
    querystring = require('querystring');

Faye.logger = function(message) {
  sys.puts(message);
};

Faye.withDataFor = function(transport, callback, scope) {
  var data = '';
  transport.addListener('data', function(chunk) { data += chunk });
  transport.addListener('end', function() {
    callback.call(scope, data);
  });
};

Faye.NodeAdapter = Faye.Class({
  DEFAULT_ENDPOINT: '/bayeux',
  SCRIPT_PATH:      path.dirname(__filename) + '/faye-browser-min.js',
  
  TYPE_JSON:    {'Content-Type': 'application/json'},
  TYPE_SCRIPT:  {'Content-Type': 'text/javascript'},
  TYPE_TEXT:    {'Content-Type': 'text/plain'},
  
  initialize: function(options) {
    this._options    = options || {};
    this._endpoint   = this._options.mount || this.DEFAULT_ENDPOINT;
    this._endpointRe = new RegExp('^' + this._endpoint + '(/[^/]*)*(\\.js)?$');
    this._server     = new Faye.Server(this._options);
    this._failed     = {};
    
    var extensions = this._options.extensions;
    if (!extensions) return;
    Faye.each([].concat(extensions), this.addExtension, this);
  },
  
  addExtension: function(extension) {
    return this._server.addExtension(extension);
  },
  
  removeExtension: function(extension) {
    return this._server.removeExtension(extension);
  },
  
  getClient: function() {
    return this._client = this._client || new Faye.Client(this._server);
  },
  
  listen: function(port) {
    var httpServer = http.createServer(function() {});
    this.attach(httpServer);
    httpServer.listen(port);
  },
  
  attach: function(httpServer) {
    this._overrideListeners(httpServer, 'request', 'handle');
    this._overrideListeners(httpServer, 'upgrade', 'handleUpgrade');
  },
  
  _overrideListeners: function(httpServer, event, method) {
    var listeners = httpServer.listeners(event),
        self      = this;
    
    httpServer.removeAllListeners(event);
    
    httpServer.addListener(event, function(request) {
      if (self.check(request)) return self[method].apply(self, arguments);
      
      for (var i = 0, n = listeners.length; i < n; i++)
        listeners[i].apply(this, arguments);
    });
  },
  
  check: function(request) {
    var path = url.parse(request.url, true).pathname;
    return !!this._endpointRe.test(path);
  },
  
  loadClientScript: function(callback) {
    if (this._clientScript) return callback(this._clientScript);
    var self = this;
    fs.readFile(this.SCRIPT_PATH, function(err, content) {
      self._clientScript = content;
      callback(content);
    });
  },
  
  handle: function(request, response) {
    var requestUrl = url.parse(request.url, true),
        self = this, data;
    
    if (/\.js$/.test(requestUrl.pathname)) {
      this.loadClientScript(function(content) {
        response.writeHead(200, self.TYPE_SCRIPT);
        response.write(content);
        response.end();
      });
      
    } else {
      var isGet = (request.method === 'GET');
      
      if (isGet)
        this._callWithParams(request, response, requestUrl.query);
      
      else
        Faye.withDataFor(request, function(data) {
          var type   = request.headers['content-type'].split(';')[0],
              
              params = (type === 'application/json')
                     ? {message: data}
                     : querystring.parse(data);
          
          self._callWithParams(request, response, params);
        });
    }
    return true;
  },
  
  handleUpgrade: function(request, socket, head) {
    var socket = new Faye.WebSocket(request, head),
        self   = this;
    
    var send = function(messages) {
      try {
        socket.send(JSON.stringify(messages));
      } catch (e) {
        self._failed[socket.clientId] = messages;
      }
    };
    
    socket.onmessage = function(message) {
      try {
        var message  = JSON.parse(message.data),
            clientId = self._server.determineClient(message),
            failed   = null;
        
        if (clientId) {
          socket.clientId = clientId;
          if (failed = self._failed[clientId]) {
            delete self._failed[clientId];
            send(failed);
          }
        }
        
        self._server.process(message, socket, send);
      } catch (e) {}
    };
  },
  
  _callWithParams: function(request, response, params) {
    try {
      var message = JSON.parse(params.message),
          jsonp   = params.jsonp || Faye.JSONP_CALLBACK,
          isGet   = (request.method === 'GET'),
          type    = isGet ? this.TYPE_SCRIPT : this.TYPE_JSON;
      
      if (isGet) this._server.flushConnection(message);
      
      this._server.process(message, false, function(replies) {
        var body = JSON.stringify(replies);
        if (isGet) body = jsonp + '(' + body + ');';
        response.writeHead(200, type);
        response.write(body);
        response.end();
      });
    } catch (e) {
      response.writeHead(400, this.TYPE_TEXT);
      response.write('Bad request');
      response.end();
    }
  }
});

exports.NodeAdapter = Faye.NodeAdapter;
exports.Client = Faye.Client;
exports.Logging = Faye.Logging;