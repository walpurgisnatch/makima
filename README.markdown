# Makima


## Usage
Start makima  
`ros roswell/makima.ros`

### Create watcher
```
(create-html-watcher
  :name "html-test"
  :page "http://example.xyz/page"
  :target ".link"
  :parser #'ss:parse-text
  :interval 300
  :handlers (handler-list (:recordp t)))
```

### Test
`(asdf:test-system :makima)`

## Installation

### With roswell
`ros install walpurgisnatch/makima`  
