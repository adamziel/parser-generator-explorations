/**
 * This file was generated from json.peg
 * See https://canopy.jcoglan.com/ for documentation
 */

(function () {
  'use strict';

  function TreeNode (text, offset, elements) {
    this.text = text;
    this.offset = offset;
    this.elements = elements;
  }

  TreeNode.prototype.forEach = function (block, context) {
    for (var el = this.elements, i = 0, n = el.length; i < n; i++) {
      block.call(context, el[i], i, el);
    }
  };

  if (typeof Symbol !== 'undefined' && Symbol.iterator) {
    TreeNode.prototype[Symbol.iterator] = function () {
      return this.elements[Symbol.iterator]();
    };
  }

  var TreeNode1 = function (text, offset, elements) {
    TreeNode.apply(this, arguments);
    this['_'] = elements[3];
  };
  inherit(TreeNode1, TreeNode);

  var TreeNode2 = function (text, offset, elements) {
    TreeNode.apply(this, arguments);
    this['value'] = elements[0];
  };
  inherit(TreeNode2, TreeNode);

  var TreeNode3 = function (text, offset, elements) {
    TreeNode.apply(this, arguments);
    this['_'] = elements[2];
    this['value'] = elements[3];
  };
  inherit(TreeNode3, TreeNode);

  var TreeNode4 = function (text, offset, elements) {
    TreeNode.apply(this, arguments);
    this['_'] = elements[3];
  };
  inherit(TreeNode4, TreeNode);

  var TreeNode5 = function (text, offset, elements) {
    TreeNode.apply(this, arguments);
    this['string'] = elements[0];
    this['_'] = elements[3];
    this['value'] = elements[4];
  };
  inherit(TreeNode5, TreeNode);

  var TreeNode6 = function (text, offset, elements) {
    TreeNode.apply(this, arguments);
    this['_'] = elements[6];
    this['string'] = elements[3];
    this['value'] = elements[7];
  };
  inherit(TreeNode6, TreeNode);

  var FAILURE = {};

  var Grammar = {
    _read_value () {
      var address0 = FAILURE, index0 = this._offset;
      this._cache._value = this._cache._value || {};
      var cached = this._cache._value[index0];
      if (cached) {
        this._offset = cached[1];
        return cached[0];
      }
      var index1 = this._offset;
      address0 = this._read_string();
      if (address0 === FAILURE) {
        this._offset = index1;
        address0 = this._read_number();
        if (address0 === FAILURE) {
          this._offset = index1;
          address0 = this._read_object();
          if (address0 === FAILURE) {
            this._offset = index1;
            address0 = this._read_array();
            if (address0 === FAILURE) {
              this._offset = index1;
              address0 = this._read_special();
              if (address0 === FAILURE) {
                this._offset = index1;
              }
            }
          }
        }
      }
      this._cache._value[index0] = [address0, this._offset];
      return address0;
    },

    _read_array () {
      var address0 = FAILURE, index0 = this._offset;
      this._cache._array = this._cache._array || {};
      var cached = this._cache._array[index0];
      if (cached) {
        this._offset = cached[1];
        return cached[0];
      }
      var index1 = this._offset, elements0 = new Array(5);
      var address1 = FAILURE;
      var chunk0 = null, max0 = this._offset + 1;
      if (max0 <= this._inputSize) {
        chunk0 = this._input.substring(this._offset, max0);
      }
      if (chunk0 === '[') {
        address1 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
        this._offset = this._offset + 1;
      } else {
        address1 = FAILURE;
        if (this._offset > this._failure) {
          this._failure = this._offset;
          this._expected = [];
        }
        if (this._offset === this._failure) {
          this._expected.push(['json::array', '"["']);
        }
      }
      if (address1 !== FAILURE) {
        elements0[0] = address1;
        var address2 = FAILURE;
        address2 = this._read__();
        if (address2 !== FAILURE) {
          elements0[1] = address2;
          var address3 = FAILURE;
          var index2 = this._offset;
          var index3 = this._offset, elements1 = new Array(2);
          var address4 = FAILURE;
          address4 = this._read_value();
          if (address4 !== FAILURE) {
            elements1[0] = address4;
            var address5 = FAILURE;
            var index4 = this._offset, elements2 = [], address6 = null;
            while (true) {
              var index5 = this._offset, elements3 = new Array(4);
              var address7 = FAILURE;
              address7 = this._read__();
              if (address7 !== FAILURE) {
                elements3[0] = address7;
                var address8 = FAILURE;
                var chunk1 = null, max1 = this._offset + 1;
                if (max1 <= this._inputSize) {
                  chunk1 = this._input.substring(this._offset, max1);
                }
                if (chunk1 === ',') {
                  address8 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
                  this._offset = this._offset + 1;
                } else {
                  address8 = FAILURE;
                  if (this._offset > this._failure) {
                    this._failure = this._offset;
                    this._expected = [];
                  }
                  if (this._offset === this._failure) {
                    this._expected.push(['json::array', '","']);
                  }
                }
                if (address8 !== FAILURE) {
                  elements3[1] = address8;
                  var address9 = FAILURE;
                  address9 = this._read__();
                  if (address9 !== FAILURE) {
                    elements3[2] = address9;
                    var address10 = FAILURE;
                    address10 = this._read_value();
                    if (address10 !== FAILURE) {
                      elements3[3] = address10;
                    } else {
                      elements3 = null;
                      this._offset = index5;
                    }
                  } else {
                    elements3 = null;
                    this._offset = index5;
                  }
                } else {
                  elements3 = null;
                  this._offset = index5;
                }
              } else {
                elements3 = null;
                this._offset = index5;
              }
              if (elements3 === null) {
                address6 = FAILURE;
              } else {
                address6 = new TreeNode3(this._input.substring(index5, this._offset), index5, elements3);
                this._offset = this._offset;
              }
              if (address6 !== FAILURE) {
                elements2.push(address6);
              } else {
                break;
              }
            }
            if (elements2.length >= 0) {
              address5 = new TreeNode(this._input.substring(index4, this._offset), index4, elements2);
              this._offset = this._offset;
            } else {
              address5 = FAILURE;
            }
            if (address5 !== FAILURE) {
              elements1[1] = address5;
            } else {
              elements1 = null;
              this._offset = index3;
            }
          } else {
            elements1 = null;
            this._offset = index3;
          }
          if (elements1 === null) {
            address3 = FAILURE;
          } else {
            address3 = new TreeNode2(this._input.substring(index3, this._offset), index3, elements1);
            this._offset = this._offset;
          }
          if (address3 === FAILURE) {
            address3 = new TreeNode(this._input.substring(index2, index2), index2, []);
            this._offset = index2;
          }
          if (address3 !== FAILURE) {
            elements0[2] = address3;
            var address11 = FAILURE;
            address11 = this._read__();
            if (address11 !== FAILURE) {
              elements0[3] = address11;
              var address12 = FAILURE;
              var chunk2 = null, max2 = this._offset + 1;
              if (max2 <= this._inputSize) {
                chunk2 = this._input.substring(this._offset, max2);
              }
              if (chunk2 === ']') {
                address12 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
                this._offset = this._offset + 1;
              } else {
                address12 = FAILURE;
                if (this._offset > this._failure) {
                  this._failure = this._offset;
                  this._expected = [];
                }
                if (this._offset === this._failure) {
                  this._expected.push(['json::array', '"]"']);
                }
              }
              if (address12 !== FAILURE) {
                elements0[4] = address12;
              } else {
                elements0 = null;
                this._offset = index1;
              }
            } else {
              elements0 = null;
              this._offset = index1;
            }
          } else {
            elements0 = null;
            this._offset = index1;
          }
        } else {
          elements0 = null;
          this._offset = index1;
        }
      } else {
        elements0 = null;
        this._offset = index1;
      }
      if (elements0 === null) {
        address0 = FAILURE;
      } else {
        address0 = new TreeNode1(this._input.substring(index1, this._offset), index1, elements0);
        this._offset = this._offset;
      }
      if (address0 !== FAILURE) {
        Object.assign(address0, this._types.ArrayNode);
      }
      this._cache._array[index0] = [address0, this._offset];
      return address0;
    },

    _read_object () {
      var address0 = FAILURE, index0 = this._offset;
      this._cache._object = this._cache._object || {};
      var cached = this._cache._object[index0];
      if (cached) {
        this._offset = cached[1];
        return cached[0];
      }
      var index1 = this._offset, elements0 = new Array(5);
      var address1 = FAILURE;
      var chunk0 = null, max0 = this._offset + 1;
      if (max0 <= this._inputSize) {
        chunk0 = this._input.substring(this._offset, max0);
      }
      if (chunk0 === '{') {
        address1 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
        this._offset = this._offset + 1;
      } else {
        address1 = FAILURE;
        if (this._offset > this._failure) {
          this._failure = this._offset;
          this._expected = [];
        }
        if (this._offset === this._failure) {
          this._expected.push(['json::object', '"{"']);
        }
      }
      if (address1 !== FAILURE) {
        elements0[0] = address1;
        var address2 = FAILURE;
        address2 = this._read__();
        if (address2 !== FAILURE) {
          elements0[1] = address2;
          var address3 = FAILURE;
          var index2 = this._offset;
          var index3 = this._offset, elements1 = new Array(2);
          var address4 = FAILURE;
          var index4 = this._offset, elements2 = new Array(5);
          var address5 = FAILURE;
          address5 = this._read_string();
          if (address5 !== FAILURE) {
            elements2[0] = address5;
            var address6 = FAILURE;
            address6 = this._read__();
            if (address6 !== FAILURE) {
              elements2[1] = address6;
              var address7 = FAILURE;
              var chunk1 = null, max1 = this._offset + 1;
              if (max1 <= this._inputSize) {
                chunk1 = this._input.substring(this._offset, max1);
              }
              if (chunk1 === ':') {
                address7 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
                this._offset = this._offset + 1;
              } else {
                address7 = FAILURE;
                if (this._offset > this._failure) {
                  this._failure = this._offset;
                  this._expected = [];
                }
                if (this._offset === this._failure) {
                  this._expected.push(['json::object', '":"']);
                }
              }
              if (address7 !== FAILURE) {
                elements2[2] = address7;
                var address8 = FAILURE;
                address8 = this._read__();
                if (address8 !== FAILURE) {
                  elements2[3] = address8;
                  var address9 = FAILURE;
                  address9 = this._read_value();
                  if (address9 !== FAILURE) {
                    elements2[4] = address9;
                  } else {
                    elements2 = null;
                    this._offset = index4;
                  }
                } else {
                  elements2 = null;
                  this._offset = index4;
                }
              } else {
                elements2 = null;
                this._offset = index4;
              }
            } else {
              elements2 = null;
              this._offset = index4;
            }
          } else {
            elements2 = null;
            this._offset = index4;
          }
          if (elements2 === null) {
            address4 = FAILURE;
          } else {
            address4 = new TreeNode5(this._input.substring(index4, this._offset), index4, elements2);
            this._offset = this._offset;
          }
          if (address4 !== FAILURE) {
            elements1[0] = address4;
            var address10 = FAILURE;
            var index5 = this._offset, elements3 = [], address11 = null;
            while (true) {
              var index6 = this._offset, elements4 = new Array(8);
              var address12 = FAILURE;
              address12 = this._read__();
              if (address12 !== FAILURE) {
                elements4[0] = address12;
                var address13 = FAILURE;
                var chunk2 = null, max2 = this._offset + 1;
                if (max2 <= this._inputSize) {
                  chunk2 = this._input.substring(this._offset, max2);
                }
                if (chunk2 === ',') {
                  address13 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
                  this._offset = this._offset + 1;
                } else {
                  address13 = FAILURE;
                  if (this._offset > this._failure) {
                    this._failure = this._offset;
                    this._expected = [];
                  }
                  if (this._offset === this._failure) {
                    this._expected.push(['json::object', '","']);
                  }
                }
                if (address13 !== FAILURE) {
                  elements4[1] = address13;
                  var address14 = FAILURE;
                  address14 = this._read__();
                  if (address14 !== FAILURE) {
                    elements4[2] = address14;
                    var address15 = FAILURE;
                    address15 = this._read_string();
                    if (address15 !== FAILURE) {
                      elements4[3] = address15;
                      var address16 = FAILURE;
                      address16 = this._read__();
                      if (address16 !== FAILURE) {
                        elements4[4] = address16;
                        var address17 = FAILURE;
                        var chunk3 = null, max3 = this._offset + 1;
                        if (max3 <= this._inputSize) {
                          chunk3 = this._input.substring(this._offset, max3);
                        }
                        if (chunk3 === ':') {
                          address17 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
                          this._offset = this._offset + 1;
                        } else {
                          address17 = FAILURE;
                          if (this._offset > this._failure) {
                            this._failure = this._offset;
                            this._expected = [];
                          }
                          if (this._offset === this._failure) {
                            this._expected.push(['json::object', '":"']);
                          }
                        }
                        if (address17 !== FAILURE) {
                          elements4[5] = address17;
                          var address18 = FAILURE;
                          address18 = this._read__();
                          if (address18 !== FAILURE) {
                            elements4[6] = address18;
                            var address19 = FAILURE;
                            address19 = this._read_value();
                            if (address19 !== FAILURE) {
                              elements4[7] = address19;
                            } else {
                              elements4 = null;
                              this._offset = index6;
                            }
                          } else {
                            elements4 = null;
                            this._offset = index6;
                          }
                        } else {
                          elements4 = null;
                          this._offset = index6;
                        }
                      } else {
                        elements4 = null;
                        this._offset = index6;
                      }
                    } else {
                      elements4 = null;
                      this._offset = index6;
                    }
                  } else {
                    elements4 = null;
                    this._offset = index6;
                  }
                } else {
                  elements4 = null;
                  this._offset = index6;
                }
              } else {
                elements4 = null;
                this._offset = index6;
              }
              if (elements4 === null) {
                address11 = FAILURE;
              } else {
                address11 = new TreeNode6(this._input.substring(index6, this._offset), index6, elements4);
                this._offset = this._offset;
              }
              if (address11 !== FAILURE) {
                elements3.push(address11);
              } else {
                break;
              }
            }
            if (elements3.length >= 0) {
              address10 = new TreeNode(this._input.substring(index5, this._offset), index5, elements3);
              this._offset = this._offset;
            } else {
              address10 = FAILURE;
            }
            if (address10 !== FAILURE) {
              elements1[1] = address10;
            } else {
              elements1 = null;
              this._offset = index3;
            }
          } else {
            elements1 = null;
            this._offset = index3;
          }
          if (elements1 === null) {
            address3 = FAILURE;
          } else {
            address3 = new TreeNode(this._input.substring(index3, this._offset), index3, elements1);
            this._offset = this._offset;
          }
          if (address3 === FAILURE) {
            address3 = new TreeNode(this._input.substring(index2, index2), index2, []);
            this._offset = index2;
          }
          if (address3 !== FAILURE) {
            elements0[2] = address3;
            var address20 = FAILURE;
            address20 = this._read__();
            if (address20 !== FAILURE) {
              elements0[3] = address20;
              var address21 = FAILURE;
              var chunk4 = null, max4 = this._offset + 1;
              if (max4 <= this._inputSize) {
                chunk4 = this._input.substring(this._offset, max4);
              }
              if (chunk4 === '}') {
                address21 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
                this._offset = this._offset + 1;
              } else {
                address21 = FAILURE;
                if (this._offset > this._failure) {
                  this._failure = this._offset;
                  this._expected = [];
                }
                if (this._offset === this._failure) {
                  this._expected.push(['json::object', '"}"']);
                }
              }
              if (address21 !== FAILURE) {
                elements0[4] = address21;
              } else {
                elements0 = null;
                this._offset = index1;
              }
            } else {
              elements0 = null;
              this._offset = index1;
            }
          } else {
            elements0 = null;
            this._offset = index1;
          }
        } else {
          elements0 = null;
          this._offset = index1;
        }
      } else {
        elements0 = null;
        this._offset = index1;
      }
      if (elements0 === null) {
        address0 = FAILURE;
      } else {
        address0 = new TreeNode4(this._input.substring(index1, this._offset), index1, elements0);
        this._offset = this._offset;
      }
      if (address0 !== FAILURE) {
        Object.assign(address0, this._types.ObjectNode);
      }
      this._cache._object[index0] = [address0, this._offset];
      return address0;
    },

    _read_string () {
      var address0 = FAILURE, index0 = this._offset;
      this._cache._string = this._cache._string || {};
      var cached = this._cache._string[index0];
      if (cached) {
        this._offset = cached[1];
        return cached[0];
      }
      var index1 = this._offset, elements0 = new Array(3);
      var address1 = FAILURE;
      var chunk0 = null, max0 = this._offset + 1;
      if (max0 <= this._inputSize) {
        chunk0 = this._input.substring(this._offset, max0);
      }
      if (chunk0 === '"') {
        address1 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
        this._offset = this._offset + 1;
      } else {
        address1 = FAILURE;
        if (this._offset > this._failure) {
          this._failure = this._offset;
          this._expected = [];
        }
        if (this._offset === this._failure) {
          this._expected.push(['json::string', '"\\""']);
        }
      }
      if (address1 !== FAILURE) {
        elements0[0] = address1;
        var address2 = FAILURE;
        var index2 = this._offset, elements1 = [], address3 = null;
        while (true) {
          var index3 = this._offset;
          var chunk1 = null, max1 = this._offset + 1;
          if (max1 <= this._inputSize) {
            chunk1 = this._input.substring(this._offset, max1);
          }
          if (chunk1 !== null && /^[^"\\]/.test(chunk1)) {
            address3 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
            this._offset = this._offset + 1;
          } else {
            address3 = FAILURE;
            if (this._offset > this._failure) {
              this._failure = this._offset;
              this._expected = [];
            }
            if (this._offset === this._failure) {
              this._expected.push(['json::string', '[^"\\\\]']);
            }
          }
          if (address3 === FAILURE) {
            this._offset = index3;
            var index4 = this._offset, elements2 = new Array(2);
            var address4 = FAILURE;
            var chunk2 = null, max2 = this._offset + 1;
            if (max2 <= this._inputSize) {
              chunk2 = this._input.substring(this._offset, max2);
            }
            if (chunk2 === '\\') {
              address4 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
              this._offset = this._offset + 1;
            } else {
              address4 = FAILURE;
              if (this._offset > this._failure) {
                this._failure = this._offset;
                this._expected = [];
              }
              if (this._offset === this._failure) {
                this._expected.push(['json::string', '"\\\\"']);
              }
            }
            if (address4 !== FAILURE) {
              elements2[0] = address4;
              var address5 = FAILURE;
              var chunk3 = null, max3 = this._offset + 1;
              if (max3 <= this._inputSize) {
                chunk3 = this._input.substring(this._offset, max3);
              }
              if (chunk3 !== null && /^["bfnrt\\/]/.test(chunk3)) {
                address5 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
                this._offset = this._offset + 1;
              } else {
                address5 = FAILURE;
                if (this._offset > this._failure) {
                  this._failure = this._offset;
                  this._expected = [];
                }
                if (this._offset === this._failure) {
                  this._expected.push(['json::string', '["bfnrt\\\\/]']);
                }
              }
              if (address5 !== FAILURE) {
                elements2[1] = address5;
              } else {
                elements2 = null;
                this._offset = index4;
              }
            } else {
              elements2 = null;
              this._offset = index4;
            }
            if (elements2 === null) {
              address3 = FAILURE;
            } else {
              address3 = new TreeNode(this._input.substring(index4, this._offset), index4, elements2);
              this._offset = this._offset;
            }
            if (address3 === FAILURE) {
              this._offset = index3;
              address3 = this._read_hex();
              if (address3 === FAILURE) {
                this._offset = index3;
              }
            }
          }
          if (address3 !== FAILURE) {
            elements1.push(address3);
          } else {
            break;
          }
        }
        if (elements1.length >= 0) {
          address2 = new TreeNode(this._input.substring(index2, this._offset), index2, elements1);
          this._offset = this._offset;
        } else {
          address2 = FAILURE;
        }
        if (address2 !== FAILURE) {
          elements0[1] = address2;
          var address6 = FAILURE;
          var chunk4 = null, max4 = this._offset + 1;
          if (max4 <= this._inputSize) {
            chunk4 = this._input.substring(this._offset, max4);
          }
          if (chunk4 === '"') {
            address6 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
            this._offset = this._offset + 1;
          } else {
            address6 = FAILURE;
            if (this._offset > this._failure) {
              this._failure = this._offset;
              this._expected = [];
            }
            if (this._offset === this._failure) {
              this._expected.push(['json::string', '"\\""']);
            }
          }
          if (address6 !== FAILURE) {
            elements0[2] = address6;
          } else {
            elements0 = null;
            this._offset = index1;
          }
        } else {
          elements0 = null;
          this._offset = index1;
        }
      } else {
        elements0 = null;
        this._offset = index1;
      }
      if (elements0 === null) {
        address0 = FAILURE;
      } else {
        address0 = new TreeNode(this._input.substring(index1, this._offset), index1, elements0);
        this._offset = this._offset;
      }
      if (address0 !== FAILURE) {
        Object.assign(address0, this._types.StringNode);
      }
      this._cache._string[index0] = [address0, this._offset];
      return address0;
    },

    _read_number () {
      var address0 = FAILURE, index0 = this._offset;
      this._cache._number = this._cache._number || {};
      var cached = this._cache._number[index0];
      if (cached) {
        this._offset = cached[1];
        return cached[0];
      }
      var index1 = this._offset, elements0 = new Array(2);
      var address1 = FAILURE;
      var index2 = this._offset;
      var chunk0 = null, max0 = this._offset + 1;
      if (max0 <= this._inputSize) {
        chunk0 = this._input.substring(this._offset, max0);
      }
      if (chunk0 === '-') {
        address1 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
        this._offset = this._offset + 1;
      } else {
        address1 = FAILURE;
        if (this._offset > this._failure) {
          this._failure = this._offset;
          this._expected = [];
        }
        if (this._offset === this._failure) {
          this._expected.push(['json::number', '"-"']);
        }
      }
      if (address1 === FAILURE) {
        address1 = new TreeNode(this._input.substring(index2, index2), index2, []);
        this._offset = index2;
      }
      if (address1 !== FAILURE) {
        elements0[0] = address1;
        var address2 = FAILURE;
        var index3 = this._offset, elements1 = new Array(3);
        var address3 = FAILURE;
        var index4 = this._offset;
        var chunk1 = null, max1 = this._offset + 1;
        if (max1 <= this._inputSize) {
          chunk1 = this._input.substring(this._offset, max1);
        }
        if (chunk1 === '0') {
          address3 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
          this._offset = this._offset + 1;
        } else {
          address3 = FAILURE;
          if (this._offset > this._failure) {
            this._failure = this._offset;
            this._expected = [];
          }
          if (this._offset === this._failure) {
            this._expected.push(['json::number', '"0"']);
          }
        }
        if (address3 === FAILURE) {
          this._offset = index4;
          var index5 = this._offset, elements2 = new Array(2);
          var address4 = FAILURE;
          var chunk2 = null, max2 = this._offset + 1;
          if (max2 <= this._inputSize) {
            chunk2 = this._input.substring(this._offset, max2);
          }
          if (chunk2 !== null && /^[1-9]/.test(chunk2)) {
            address4 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
            this._offset = this._offset + 1;
          } else {
            address4 = FAILURE;
            if (this._offset > this._failure) {
              this._failure = this._offset;
              this._expected = [];
            }
            if (this._offset === this._failure) {
              this._expected.push(['json::number', '[1-9]']);
            }
          }
          if (address4 !== FAILURE) {
            elements2[0] = address4;
            var address5 = FAILURE;
            var index6 = this._offset, elements3 = [], address6 = null;
            while (true) {
              var chunk3 = null, max3 = this._offset + 1;
              if (max3 <= this._inputSize) {
                chunk3 = this._input.substring(this._offset, max3);
              }
              if (chunk3 !== null && /^[0-9]/.test(chunk3)) {
                address6 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
                this._offset = this._offset + 1;
              } else {
                address6 = FAILURE;
                if (this._offset > this._failure) {
                  this._failure = this._offset;
                  this._expected = [];
                }
                if (this._offset === this._failure) {
                  this._expected.push(['json::number', '[0-9]']);
                }
              }
              if (address6 !== FAILURE) {
                elements3.push(address6);
              } else {
                break;
              }
            }
            if (elements3.length >= 0) {
              address5 = new TreeNode(this._input.substring(index6, this._offset), index6, elements3);
              this._offset = this._offset;
            } else {
              address5 = FAILURE;
            }
            if (address5 !== FAILURE) {
              elements2[1] = address5;
            } else {
              elements2 = null;
              this._offset = index5;
            }
          } else {
            elements2 = null;
            this._offset = index5;
          }
          if (elements2 === null) {
            address3 = FAILURE;
          } else {
            address3 = new TreeNode(this._input.substring(index5, this._offset), index5, elements2);
            this._offset = this._offset;
          }
          if (address3 === FAILURE) {
            this._offset = index4;
          }
        }
        if (address3 !== FAILURE) {
          elements1[0] = address3;
          var address7 = FAILURE;
          var index7 = this._offset;
          var index8 = this._offset, elements4 = new Array(2);
          var address8 = FAILURE;
          var chunk4 = null, max4 = this._offset + 1;
          if (max4 <= this._inputSize) {
            chunk4 = this._input.substring(this._offset, max4);
          }
          if (chunk4 === '.') {
            address8 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
            this._offset = this._offset + 1;
          } else {
            address8 = FAILURE;
            if (this._offset > this._failure) {
              this._failure = this._offset;
              this._expected = [];
            }
            if (this._offset === this._failure) {
              this._expected.push(['json::number', '"."']);
            }
          }
          if (address8 !== FAILURE) {
            elements4[0] = address8;
            var address9 = FAILURE;
            var index9 = this._offset, elements5 = [], address10 = null;
            while (true) {
              var chunk5 = null, max5 = this._offset + 1;
              if (max5 <= this._inputSize) {
                chunk5 = this._input.substring(this._offset, max5);
              }
              if (chunk5 !== null && /^[0-9]/.test(chunk5)) {
                address10 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
                this._offset = this._offset + 1;
              } else {
                address10 = FAILURE;
                if (this._offset > this._failure) {
                  this._failure = this._offset;
                  this._expected = [];
                }
                if (this._offset === this._failure) {
                  this._expected.push(['json::number', '[0-9]']);
                }
              }
              if (address10 !== FAILURE) {
                elements5.push(address10);
              } else {
                break;
              }
            }
            if (elements5.length >= 1) {
              address9 = new TreeNode(this._input.substring(index9, this._offset), index9, elements5);
              this._offset = this._offset;
            } else {
              address9 = FAILURE;
            }
            if (address9 !== FAILURE) {
              elements4[1] = address9;
            } else {
              elements4 = null;
              this._offset = index8;
            }
          } else {
            elements4 = null;
            this._offset = index8;
          }
          if (elements4 === null) {
            address7 = FAILURE;
          } else {
            address7 = new TreeNode(this._input.substring(index8, this._offset), index8, elements4);
            this._offset = this._offset;
          }
          if (address7 === FAILURE) {
            address7 = new TreeNode(this._input.substring(index7, index7), index7, []);
            this._offset = index7;
          }
          if (address7 !== FAILURE) {
            elements1[1] = address7;
            var address11 = FAILURE;
            var index10 = this._offset;
            var index11 = this._offset, elements6 = new Array(3);
            var address12 = FAILURE;
            var index12 = this._offset;
            var chunk6 = null, max6 = this._offset + 1;
            if (max6 <= this._inputSize) {
              chunk6 = this._input.substring(this._offset, max6);
            }
            if (chunk6 === 'e') {
              address12 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
              this._offset = this._offset + 1;
            } else {
              address12 = FAILURE;
              if (this._offset > this._failure) {
                this._failure = this._offset;
                this._expected = [];
              }
              if (this._offset === this._failure) {
                this._expected.push(['json::number', '"e"']);
              }
            }
            if (address12 === FAILURE) {
              this._offset = index12;
              var chunk7 = null, max7 = this._offset + 1;
              if (max7 <= this._inputSize) {
                chunk7 = this._input.substring(this._offset, max7);
              }
              if (chunk7 === 'E') {
                address12 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
                this._offset = this._offset + 1;
              } else {
                address12 = FAILURE;
                if (this._offset > this._failure) {
                  this._failure = this._offset;
                  this._expected = [];
                }
                if (this._offset === this._failure) {
                  this._expected.push(['json::number', '"E"']);
                }
              }
              if (address12 === FAILURE) {
                this._offset = index12;
              }
            }
            if (address12 !== FAILURE) {
              elements6[0] = address12;
              var address13 = FAILURE;
              var index13 = this._offset;
              var index14 = this._offset;
              var chunk8 = null, max8 = this._offset + 1;
              if (max8 <= this._inputSize) {
                chunk8 = this._input.substring(this._offset, max8);
              }
              if (chunk8 === '+') {
                address13 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
                this._offset = this._offset + 1;
              } else {
                address13 = FAILURE;
                if (this._offset > this._failure) {
                  this._failure = this._offset;
                  this._expected = [];
                }
                if (this._offset === this._failure) {
                  this._expected.push(['json::number', '"+"']);
                }
              }
              if (address13 === FAILURE) {
                this._offset = index14;
                var chunk9 = null, max9 = this._offset + 1;
                if (max9 <= this._inputSize) {
                  chunk9 = this._input.substring(this._offset, max9);
                }
                if (chunk9 === '-') {
                  address13 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
                  this._offset = this._offset + 1;
                } else {
                  address13 = FAILURE;
                  if (this._offset > this._failure) {
                    this._failure = this._offset;
                    this._expected = [];
                  }
                  if (this._offset === this._failure) {
                    this._expected.push(['json::number', '"-"']);
                  }
                }
                if (address13 === FAILURE) {
                  this._offset = index14;
                }
              }
              if (address13 === FAILURE) {
                address13 = new TreeNode(this._input.substring(index13, index13), index13, []);
                this._offset = index13;
              }
              if (address13 !== FAILURE) {
                elements6[1] = address13;
                var address14 = FAILURE;
                var index15 = this._offset, elements7 = [], address15 = null;
                while (true) {
                  var chunk10 = null, max10 = this._offset + 1;
                  if (max10 <= this._inputSize) {
                    chunk10 = this._input.substring(this._offset, max10);
                  }
                  if (chunk10 !== null && /^[0-9]/.test(chunk10)) {
                    address15 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
                    this._offset = this._offset + 1;
                  } else {
                    address15 = FAILURE;
                    if (this._offset > this._failure) {
                      this._failure = this._offset;
                      this._expected = [];
                    }
                    if (this._offset === this._failure) {
                      this._expected.push(['json::number', '[0-9]']);
                    }
                  }
                  if (address15 !== FAILURE) {
                    elements7.push(address15);
                  } else {
                    break;
                  }
                }
                if (elements7.length >= 1) {
                  address14 = new TreeNode(this._input.substring(index15, this._offset), index15, elements7);
                  this._offset = this._offset;
                } else {
                  address14 = FAILURE;
                }
                if (address14 !== FAILURE) {
                  elements6[2] = address14;
                } else {
                  elements6 = null;
                  this._offset = index11;
                }
              } else {
                elements6 = null;
                this._offset = index11;
              }
            } else {
              elements6 = null;
              this._offset = index11;
            }
            if (elements6 === null) {
              address11 = FAILURE;
            } else {
              address11 = new TreeNode(this._input.substring(index11, this._offset), index11, elements6);
              this._offset = this._offset;
            }
            if (address11 === FAILURE) {
              address11 = new TreeNode(this._input.substring(index10, index10), index10, []);
              this._offset = index10;
            }
            if (address11 !== FAILURE) {
              elements1[2] = address11;
            } else {
              elements1 = null;
              this._offset = index3;
            }
          } else {
            elements1 = null;
            this._offset = index3;
          }
        } else {
          elements1 = null;
          this._offset = index3;
        }
        if (elements1 === null) {
          address2 = FAILURE;
        } else {
          address2 = new TreeNode(this._input.substring(index3, this._offset), index3, elements1);
          this._offset = this._offset;
        }
        if (address2 !== FAILURE) {
          elements0[1] = address2;
        } else {
          elements0 = null;
          this._offset = index1;
        }
      } else {
        elements0 = null;
        this._offset = index1;
      }
      if (elements0 === null) {
        address0 = FAILURE;
      } else {
        address0 = new TreeNode(this._input.substring(index1, this._offset), index1, elements0);
        this._offset = this._offset;
      }
      if (address0 !== FAILURE) {
        Object.assign(address0, this._types.NumberNode);
      }
      this._cache._number[index0] = [address0, this._offset];
      return address0;
    },

    _read_special () {
      var address0 = FAILURE, index0 = this._offset;
      this._cache._special = this._cache._special || {};
      var cached = this._cache._special[index0];
      if (cached) {
        this._offset = cached[1];
        return cached[0];
      }
      var index1 = this._offset;
      var chunk0 = null, max0 = this._offset + 4;
      if (max0 <= this._inputSize) {
        chunk0 = this._input.substring(this._offset, max0);
      }
      if (chunk0 === 'true') {
        address0 = new TreeNode(this._input.substring(this._offset, this._offset + 4), this._offset, []);
        this._offset = this._offset + 4;
      } else {
        address0 = FAILURE;
        if (this._offset > this._failure) {
          this._failure = this._offset;
          this._expected = [];
        }
        if (this._offset === this._failure) {
          this._expected.push(['json::special', '"true"']);
        }
      }
      if (address0 === FAILURE) {
        this._offset = index1;
        var chunk1 = null, max1 = this._offset + 5;
        if (max1 <= this._inputSize) {
          chunk1 = this._input.substring(this._offset, max1);
        }
        if (chunk1 === 'false') {
          address0 = new TreeNode(this._input.substring(this._offset, this._offset + 5), this._offset, []);
          this._offset = this._offset + 5;
        } else {
          address0 = FAILURE;
          if (this._offset > this._failure) {
            this._failure = this._offset;
            this._expected = [];
          }
          if (this._offset === this._failure) {
            this._expected.push(['json::special', '"false"']);
          }
        }
        if (address0 === FAILURE) {
          this._offset = index1;
          var chunk2 = null, max2 = this._offset + 18;
          if (max2 <= this._inputSize) {
            chunk2 = this._input.substring(this._offset, max2);
          }
          if (chunk2 === 'null <SpecialNode>') {
            address0 = new TreeNode(this._input.substring(this._offset, this._offset + 18), this._offset, []);
            this._offset = this._offset + 18;
          } else {
            address0 = FAILURE;
            if (this._offset > this._failure) {
              this._failure = this._offset;
              this._expected = [];
            }
            if (this._offset === this._failure) {
              this._expected.push(['json::special', '"null <SpecialNode>"']);
            }
          }
          if (address0 === FAILURE) {
            this._offset = index1;
          }
        }
      }
      this._cache._special[index0] = [address0, this._offset];
      return address0;
    },

    _read_hex () {
      var address0 = FAILURE, index0 = this._offset;
      this._cache._hex = this._cache._hex || {};
      var cached = this._cache._hex[index0];
      if (cached) {
        this._offset = cached[1];
        return cached[0];
      }
      var index1 = this._offset, elements0 = new Array(5);
      var address1 = FAILURE;
      var chunk0 = null, max0 = this._offset + 2;
      if (max0 <= this._inputSize) {
        chunk0 = this._input.substring(this._offset, max0);
      }
      if (chunk0 === '\\u') {
        address1 = new TreeNode(this._input.substring(this._offset, this._offset + 2), this._offset, []);
        this._offset = this._offset + 2;
      } else {
        address1 = FAILURE;
        if (this._offset > this._failure) {
          this._failure = this._offset;
          this._expected = [];
        }
        if (this._offset === this._failure) {
          this._expected.push(['json::hex', '"\\\\u"']);
        }
      }
      if (address1 !== FAILURE) {
        elements0[0] = address1;
        var address2 = FAILURE;
        var chunk1 = null, max1 = this._offset + 1;
        if (max1 <= this._inputSize) {
          chunk1 = this._input.substring(this._offset, max1);
        }
        if (chunk1 !== null && /^[0-9a-fA-F]/.test(chunk1)) {
          address2 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
          this._offset = this._offset + 1;
        } else {
          address2 = FAILURE;
          if (this._offset > this._failure) {
            this._failure = this._offset;
            this._expected = [];
          }
          if (this._offset === this._failure) {
            this._expected.push(['json::hex', '[0-9a-fA-F]']);
          }
        }
        if (address2 !== FAILURE) {
          elements0[1] = address2;
          var address3 = FAILURE;
          var chunk2 = null, max2 = this._offset + 1;
          if (max2 <= this._inputSize) {
            chunk2 = this._input.substring(this._offset, max2);
          }
          if (chunk2 !== null && /^[0-9a-fA-F]/.test(chunk2)) {
            address3 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
            this._offset = this._offset + 1;
          } else {
            address3 = FAILURE;
            if (this._offset > this._failure) {
              this._failure = this._offset;
              this._expected = [];
            }
            if (this._offset === this._failure) {
              this._expected.push(['json::hex', '[0-9a-fA-F]']);
            }
          }
          if (address3 !== FAILURE) {
            elements0[2] = address3;
            var address4 = FAILURE;
            var chunk3 = null, max3 = this._offset + 1;
            if (max3 <= this._inputSize) {
              chunk3 = this._input.substring(this._offset, max3);
            }
            if (chunk3 !== null && /^[0-9a-fA-F]/.test(chunk3)) {
              address4 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
              this._offset = this._offset + 1;
            } else {
              address4 = FAILURE;
              if (this._offset > this._failure) {
                this._failure = this._offset;
                this._expected = [];
              }
              if (this._offset === this._failure) {
                this._expected.push(['json::hex', '[0-9a-fA-F]']);
              }
            }
            if (address4 !== FAILURE) {
              elements0[3] = address4;
              var address5 = FAILURE;
              var chunk4 = null, max4 = this._offset + 1;
              if (max4 <= this._inputSize) {
                chunk4 = this._input.substring(this._offset, max4);
              }
              if (chunk4 !== null && /^[0-9a-fA-F]/.test(chunk4)) {
                address5 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
                this._offset = this._offset + 1;
              } else {
                address5 = FAILURE;
                if (this._offset > this._failure) {
                  this._failure = this._offset;
                  this._expected = [];
                }
                if (this._offset === this._failure) {
                  this._expected.push(['json::hex', '[0-9a-fA-F]']);
                }
              }
              if (address5 !== FAILURE) {
                elements0[4] = address5;
              } else {
                elements0 = null;
                this._offset = index1;
              }
            } else {
              elements0 = null;
              this._offset = index1;
            }
          } else {
            elements0 = null;
            this._offset = index1;
          }
        } else {
          elements0 = null;
          this._offset = index1;
        }
      } else {
        elements0 = null;
        this._offset = index1;
      }
      if (elements0 === null) {
        address0 = FAILURE;
      } else {
        address0 = new TreeNode(this._input.substring(index1, this._offset), index1, elements0);
        this._offset = this._offset;
      }
      this._cache._hex[index0] = [address0, this._offset];
      return address0;
    },

    _read__ () {
      var address0 = FAILURE, index0 = this._offset;
      this._cache.__ = this._cache.__ || {};
      var cached = this._cache.__[index0];
      if (cached) {
        this._offset = cached[1];
        return cached[0];
      }
      var index1 = this._offset, elements0 = [], address1 = null;
      while (true) {
        var chunk0 = null, max0 = this._offset + 1;
        if (max0 <= this._inputSize) {
          chunk0 = this._input.substring(this._offset, max0);
        }
        if (chunk0 !== null && /^[ \n\t]/.test(chunk0)) {
          address1 = new TreeNode(this._input.substring(this._offset, this._offset + 1), this._offset, []);
          this._offset = this._offset + 1;
        } else {
          address1 = FAILURE;
          if (this._offset > this._failure) {
            this._failure = this._offset;
            this._expected = [];
          }
          if (this._offset === this._failure) {
            this._expected.push(['json::_', '[ \\n\\t]']);
          }
        }
        if (address1 !== FAILURE) {
          elements0.push(address1);
        } else {
          break;
        }
      }
      if (elements0.length >= 0) {
        address0 = new TreeNode(this._input.substring(index1, this._offset), index1, elements0);
        this._offset = this._offset;
      } else {
        address0 = FAILURE;
      }
      this._cache.__[index0] = [address0, this._offset];
      return address0;
    }
  };

  var Parser = function(input, actions, types) {
    this._input = input;
    this._inputSize = input.length;
    this._actions = actions;
    this._types = types;
    this._offset = 0;
    this._cache = {};
    this._failure = 0;
    this._expected = [];
  };

  Parser.prototype.parse = function() {
    var tree = this._read_value();
    if (tree !== FAILURE && this._offset === this._inputSize) {
      return tree;
    }
    if (this._expected.length === 0) {
      this._failure = this._offset;
      this._expected.push(['json', '<EOF>']);
    }
    this.constructor.lastError = { offset: this._offset, expected: this._expected };
    throw new SyntaxError(formatError(this._input, this._failure, this._expected));
  };

  Object.assign(Parser.prototype, Grammar);


  function parse(input, options) {
    options = options || {};
    var parser = new Parser(input, options.actions, options.types);
    return parser.parse();
  }

  function formatError(input, offset, expected) {
    var lines = input.split(/\n/g),
        lineNo = 0,
        position = 0;

    while (position <= offset) {
      position += lines[lineNo].length + 1;
      lineNo += 1;
    }

    var line = lines[lineNo - 1],
        message = 'Line ' + lineNo + ': expected one of:\n\n';

    for (var i = 0; i < expected.length; i++) {
      message += '    - ' + expected[i][1] + ' from ' + expected[i][0] + '\n';
    }
    var number = lineNo.toString();
    while (number.length < 6) number = ' ' + number;
    message += '\n' + number + ' | ' + line + '\n';

    position -= line.length + 10;

    while (position < offset) {
      message += ' ';
      position += 1;
    }
    return message + '^';
  }

  function inherit(subclass, parent) {
    function chain () {};
    chain.prototype = parent.prototype;
    subclass.prototype = new chain();
    subclass.prototype.constructor = subclass;
  }


  var exported = { Grammar: Grammar, Parser: Parser, parse: parse };

  if (typeof require === 'function' && typeof exports === 'object') {
    Object.assign(exports, exported);
  } else {
    var ns = (typeof this === 'undefined') ? window : this;
    ns.json = exported;
  }
})();
