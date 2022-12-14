(require 'transient)

;; TODO: Check existence + cross-platform?

(defcustom qemu-default-image-directory (concat (getenv "HOME") "/Downloads/")
  "The default directory to look for OS images when calling
`qemu'. Setting this to `nil' will also disable selecting a default
file."
  :type 'directory)

(defcustom qemu-default-disk-directory nil
  "The default directory to look for OS disk files when calling `qemu'"
  :type 'directory)


(defun qemu--default-image ()
  "pick a random file from `qemu-default-image-directory' that ends in
.iso"
  (let* ((is-image-p (lambda (file-name)
		       ;; TODO: Check other extensions
		       (s-ends-with-p ".iso" file-name)))
	 (all-files (directory-files qemu-default-image-directory))
	 (all-images (cl-remove-if-not is-image-p all-files))
	 (random-file (unless (null all-images) (seq-random-elt all-images))))
    (when random-file
      (concat qemu-default-image-directory random-file))))

(defun qemu-run (&optional args)
  (interactive
   (list (transient-args 'qemu)))
  ;; Consider `start-process' in the future
  (let ((command (cl-reduce
		  (lambda (x y) (format "%s %s" x y))
		  ;; TODO: Change to detect architecture
		  (cons "qemu-system-x86_64" args))))
    (message command)
    (async-shell-command command "*qemu*")))

(transient-define-argument qemu:-m ()
  :description "Memory"
  :class 'transient-option
  :shortarg "-m"
  :argument "-m "
  ;; TODO: Add number and unit reader (M, G, etc)
  )

(transient-define-argument qemu:-smp ()
  :description "CPU SMP"
  :class 'transient-option
  :shortarg "-s"
  :argument "-smp "
  ;; TODO: add number reader
  )

(transient-define-argument qemu:-cdrom ()
  :description "CD-ROM (iso, img, ...)"
  :class 'transient-option
  :shortarg "-c"
  :argument "-cdrom "
  :reader (lambda (&rest args)
	    (interactive)
	    (read-file-name "-cdrom → "
			    qemu-default-image-directory
			    nil
			    nil))

(transient-define-argument qemu:-nic ()
  :description "Network"
  :class 'transient-option
  :shortarg "-n"
  :argument "-nic ")

(transient-define-argument qemu:-hda ()
  :description "Hard disk image (qcow2, raw, ...)"
  :class 'transient-option
  :shortarg "-h"
  :argument "-hda "
  :reader (lambda (&rest args)
	    (interactive)
	    (read-file-name "-hda → "
			    qemu-default-disk-directory)))


(transient-define-prefix qemu ()
  "A qemu[-kvm] interface for Emacs"
  :value (list "-enable-kvm"
	       "-m 8G" ;; TODO: Change to system ram / 2
	       "-smp 4" ;; TODO: Change to system cores / 2
	       "-nic user"
	       ;; What's a `when-let' lol
	       (let ((image-file (qemu--default-image)))
		 (when image-file (format "-cdrom '%s'" image-file)))
	       ;; TODO: Guess the default option based on extension
	       )
  ["Arguments"
   (qemu:-m)
   (qemu:-smp)
   (qemu:-nic)
   (qemu:-cdrom)
   (qemu:-hda)
   ("-k" "Enable KVM" "-enable-kvm")]
  ["Run"
   ("v" "Virtualize" qemu-run)
   ;; ("e" "Emulate other architectures (TODO)" nil)
   ])


(provide 'qemu)
