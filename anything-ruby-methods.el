;;; anything-ruby-methods.el --- anything + what_methods

;;; INSTALLATION:
;;
;; Add the following to your .emacs:
;;
;; (require 'anything-ruby-methods)
;; (define-key ruby-mode-map (kbd "C-c d") 'anything-ruby-methods)

(require 'anything)

(defvar anything-c-source-ruby-methods
  '((name . "Methods")
    (candidates . anything-ruby-methods-create-what-list)
    (action . (lambda (m) (insert (concat "." m))))))

(defun anything-ruby-methods ()
  (interactive)
  (let* ((input (cond
                 ((transient-region-active-p)
                  (buffer-substring-no-properties (mark) (point)))
                 (t
                  (anything-ruby-methods-line-object))))
         (output (read-string (format "'%s' to: " input))))
    (anything :sources 'anything-c-source-ruby-methods
              :buffer "*anything ruby methods*"
              :anything-quit-if-no-candidate t)))

(defun anything-ruby-methods-line-object ()
  (let ((current-point (point)))
    (save-excursion
      (beginning-of-line)
      (re-search-forward "\\S-" (point-at-eol))
      (buffer-substring-no-properties (1- (point)) current-point))))

(defun anything-ruby-methods-what ()
  (shell-command-to-string (format
                            "ruby -e 'require \"what_methods\"
begin
  puts WhatMethods::MethodFinder.find(%s, %s)
rescue
  print \"\"
end'"
                            input output)))

(defun anything-ruby-methods-create-what-list ()
  (let ((ruby-methods-output (anything-ruby-methods-what)))
    (cond ((= 0 (length ruby-methods-output))
           (message "Methods not found.")
           '())
          (t
           (split-string ruby-methods-output "\n")))))

(provide 'anything-ruby-methods)

