[I;; -*- lexical-binding: t; -*-

(require 'helm)
(require 'helm-source)
(require 'json)
(require 'php-project)

;; Use statements
(defun phpns-fix-uses-interactive () "Add missing use statements to a php file"
       (interactive)
       (save-buffer)
       (let ((phpns-json (shell-command-to-string
			  (format "cd %s && %s/.basher/cellar/bin/phpns fxu --json %s"
				  (php-project-get-root-dir)
				  (getenv "HOME")
				  buffer-file-name))))
	 (let* ((json-object-type 'hash-table)
		(json-array-type 'list)
		(json-key-type 'string)
		(phpns-json-data (json-read-from-string phpns-json)))
	   (maphash 'phpns-handle-phpns-json phpns-json-data))))

(defun phpns-handle-phpns-json (class-name candidates) "Handle key value pair of classname and FQN's"
       (if (<= (length candidates) 1)
	   (if (= 1 (length candidates))
	       (phpns-add-use (pop candidates))
	     (message "No use statement found for class \"%s\"" class-name))
	 (helm
	  :sources (helm-build-sync-source (format "Pick import for %s" class-name)
		     :candidates candidates
		     :action (lambda (fqn) "Add use statement to the file"
			       (phpns-add-use fqn)))
	  :buffer "*helm FQN source*")))

(defun phpns-add-use (fqn) "Add use statement to a php file"
       (save-excursion
         (let ((current-char (point)))
	   (goto-char (point-min))
	   (cond
	    ((re-search-forward "^use" nil t) (forward-line 1))
	    ((re-search-forward "^namespace" nil t) (forward-line 2))
	    ((re-search-forward
	      "^\\(abstract \\|/\\* final \\*/ ?\\|final \\|\\)\\(class\\|trait\\|interface\\)"
              nil )
	     (forward-line -1)
	     (phpns-goto-first-line-no-comment-up)))

	   (insert (format "use %s;%c" fqn ?\n))
	   (goto-char current-char))))

(defun phpns-goto-first-line-no-comment-up ()
  "Go up until a line is encountered that does not start with a comment."
	   (if (string-match "^\\( ?\\*\\|/\\)" (thing-at-point 'line t))
	       ((lambda ()
		  (message "heey")
		  (forward-line -1)
		  (phpns-goto-first-line-no-comment-up)))))


(defun phpns-helm () "Fuzzy finder for php projects"
       (interactive)
       (let ((helm-return (phpns-helm-action)))
	 (find-file
	  (shell-command-to-string
	   (format "cd %s && printf '%%s' \"$(pwd)/$(phpns fp %s)\""
		   (php-project-get-root-dir)
		   (shell-quote-argument helm-return))))))

(defun phpns-helm-action () "Open a helm buffer and return the picked line"
       (helm :sources (helm-build-in-file-source
		       "PHPNS Fuzzy"
		       (concat (php-project-get-root-dir) "/.cache/phpns/uses")
		       :action (lambda (candidate)
				 (let ((linum (with-helm-buffer
					       (get-text-property
						1 'helm-linum
						(helm-get-selection nil 'withprop)))))
				   (find-file (with-helm-buffer
					       (helm-attr 'candidates-file)))
				   (let ((lines (split-string (buffer-string) "\n")))
				     (kill-buffer (current-buffer))
				     (nth (- linum 1) lines)))))
	     :buffer "*PHPNS Fuzzy*"))

(defun phpns-replace-fqns ()
  (interactive)
  (let ((fqns))

    (save-excursion
      (goto-char (point-min))

      (while (re-search-forward "^use" nil t)
        (forward-line))

      (while (re-search-forward "\??\\\\[A-Za-z\\\\_]+\\\\\\([A-Za-z_]+\\)" nil t)
        (let ((fqn (match-string 0))
              (class-name (match-string 1)))
          (push fqn fqns)
          (replace-match class-name))))

    (with-temp-buffer
      (insert (string-join fqns "\n"))

      (goto-char (point-min))

      (save-excursion
        (sort-lines nil (point-min) (point-max)))

      (save-excursion
        (phpns-unique-lines))

      (setq fqns (split-string (buffer-string) "\n" nil nil)))

    (pp fqns)

    (dolist (fqn fqns)
      (if (and fqn (not (string= "" fqn)))
          (phpns-add-use fqn)))))

(defun phpns-sort-imports ()
  (interactive)
  (let ((imports)
        (sorted-imports)
        (imports-pos)
        (phpcbf-executable (concat (php-project-get-root-dir)  "/vendor/bin/phpcbf")))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward "^use .*$" nil t)
        (push (match-string-no-properties 0) imports)
        (kill-whole-line))

      (setq imports-pos (point))

      (let ((infile-name (make-temp-file "sort-imports")))

        (with-current-buffer (find-file-noselect infile-name)
          (insert (string-join imports "\n"))
          (sort-lines nil (point-min) (point-max))
          (phpns-unique-lines)

          (goto-char (point-min))
          (insert "<?php\n\n")

          (save-buffer)

          (with-temp-buffer
            (call-process phpcbf-executable
                          infile-name
                          (current-buffer)
                          nil)
            (setq sorted-imports
                  (string-join
                   (seq-filter
                    (lambda (line)
                      (string-match "^use" line))
                    (split-string (buffer-string) "\n" nil nil))
                   "\n")))))

      (goto-char imports-pos)
      (insert (concat sorted-imports "\n")))))


(defun phpns-unique-strings (strings)
  (seq-filter
   (let ((last-line nil))
     (lambda (line)
       (let ((return-line (unless (and last-line (string= last-line line))
                            line)))
         (setq last-line line)
         return-line)))
   strings))


(defun phpns-unique-lines ()
  (interactive)
  (let ((unique-lines (phpns-unique-strings (split-string (buffer-string) "\n" nil nil))))
    (erase-buffer)
    (insert (string-join unique-lines "\n"))))

(provide 'phpns)
