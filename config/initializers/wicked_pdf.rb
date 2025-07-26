# WickedPDF Global Configuration
WickedPdf.config = {
  # Path to the wkhtmltopdf executable: This usually isn't needed if using
  # one of the wkhtmltopdf-binary family of gems.
  exe_path: Rails.env.production? ? '/usr/bin/wkhtmltopdf' : nil,
  
  # Layout file to be used for all PDFs
  # (but can be overridden in `render :pdf` calls)
  # layout: 'pdf.html',
  
  # Using wkhtmltopdf without an X server can be achieved by enabling the
  # 'use_xvfb' flag. This will wrap all wkhtmltopdf calls in a xvfb-run
  # command, in order to simulate an X server.
  #
  # use_xvfb: true,
  use_xvfb: Rails.env.production?,
}