(require 'transient)

(defun qemu-run (&optional args)
  (interactive
   (list (transient-args 'qemu)))
  ;; Consider `start-process' in the future
  (async-shell-command
   (cl-reduce (lambda (x y) (concat x " " y))
	      (cons "qemu-system-x86_64"
		    args))
   "*qemu*"))


(transient-define-argument qemu:-m ()
  :description "Memory"
  :class 'transient-option
  :shortarg "-m"
  :argument "-m "
  ;; TODO: Add number and unit reader (M, G, etc)
  )


(transient-define-argument qemu:-smp ()
  :description "CPU cores"
  :class 'transient-option
  :shortarg "-s"
  :argument "-smp "
  ;; TODO: add number reader
  )


(transient-define-argument qemu:-cdrom ()
  :description "CD-ROM image"
  :class 'transient-option
  :shortarg "-c"
  :argument "-cdrom "
  :reader (lambda (&rest args) (interactive) (read-file-name "-cdrom → ")))

(transient-define-prefix qemu ()
  "A qemu[-kvm] interface for Emacs"
  :value (list "-enable-kvm"
	       "-m 8G" ;; TODO: Change to system ram / 2
	       "-smp 4" ;; TODO: Change to system cores / 2
	       ;; TODO: Guess the default option based on extension
	       )
  ["Arguments"
   (qemu:-m)
   (qemu:-smp)
   (qemu:-cdrom)
   ("-k" "Enable KVM" "-enable-kvm")]
  ["Run"
   ("v" "Virtualize (qemu-kvm)" qemu-run)
   ;; ("e" "Emulate other architectures (TODO)" nil)
   ])


(provide 'qemu)
