;;; eval-in-repl-python.el --- ESS-like eval for python  -*- lexical-binding: t; -*-

;; Copyright (C) 2014  Kazuki YOSHIDA

;; Author: Kazuki YOSHIDA <kazukiyoshida@mail.harvard.edu>
;; Keywords: tools, convenience
;; URL: https://github.com/kaz-yos/eval-in-repl
;; Version: 0.5.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.


;;; Commentary:

;; python.el-specific file for eval-in-repl
;; See below for configuration
;; https://github.com/kaz-yos/eval-in-repl/


;;; Code:

;;;
;;; Require dependencies
(require 'eval-in-repl)
(require 'python)


;;;
;;; PYTHON-MODE RELATED
;;; eir-send-to-python
(defalias 'eir-send-to-python
  (apply-partially 'eir-send-to-repl
                   ;; fun-change-to-repl
                   #'python-shell-switch-to-shell
                   ;; fun-execute
                   #'comint-send-input)
  "Send expression to *Python* and have it evaluated.")


;;; eir-eval-in-python
;; http://www.reddit.com/r/emacs/comments/1h4hyw/selecting_regions_pythonel/
;;;###autoload
(defun eir-eval-in-python ()
  "eval-in-repl for Python."
  (interactive)
  ;; Define local variables
  (let* ((script-window (selected-window)))
    ;;
    (eir-repl-start "*Python*" #'run-python)

    ;; Check if selection is present
    (if (and transient-mark-mode mark-active)
	;; If selected, send region
	(eir-send-to-python (buffer-substring-no-properties (point) (mark)))

      ;; If not selected, do all the following
      ;; Move to the beginning of line
      (beginning-of-line)
      ;; Set mark at current position
      (set-mark (point))
      ;; Go to the end of statment
      (python-nav-end-of-statement)
      ;; Go to the end of block
      (python-nav-end-of-block)
      ;; Send region if not empty
      (if (not (equal (point) (mark)))
	  ;; Add one more character for newline unless at EOF
	  ;; This does not work if the statement asks for an input.
	  (eir-send-to-python (buffer-substring-no-properties
                               (min (+ 1 (point)) (point-max))
                               (mark)))
	;; If empty, deselect region
	(setq mark-active nil))
      ;; Move to the next statement
      (python-nav-forward-statement)

      ;; Switch to the shell
      (python-shell-switch-to-shell)
      ;; Switch back to the script window
      (select-window script-window))))


(provide 'eval-in-repl-python)
;;; eval-in-repl-python.el ends here

