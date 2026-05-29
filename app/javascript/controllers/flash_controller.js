import { Controller } from "@hotwired/stimulus"
import Swal from 'sweetalert2'

export default class extends Controller {
  static values = {
    message: String,
    type: String
  }

  connect() {
    const icon = this.getIcon()
    const toast = Swal.mixin({
      toast: true,
      position: 'top-end',
      showConfirmButton: false,
      timer: 3000,
      timerProgressBar: true,
      didOpen: (toast) => {
        toast.addEventListener('mouseenter', Swal.stopTimer)
        toast.addEventListener('mouseleave', Swal.resumeTimer)
      }
    })

    toast.fire({
      icon: icon,
      title: this.messageValue
    })
  }

  getIcon() {
    switch (this.typeValue) {
      case 'notice':
      case 'success':
        return 'success'
      case 'alert':
      case 'error':
        return 'error'
      case 'warning':
        return 'warning'
      case 'info':
        return 'info'
      default:
        return 'info'
    }
  }
}
